import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Enum/RepeatFlag.dart';
import '../screens/FreehandImageCropper.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../controllers/audio_controller.dart';
import '../models/task.dart';
import 'dart:io';
import '../widgets/VoiceRecordingOverlay.dart';
import '../widgets/add_task_bottom_sheet.dart';
import 'HomeController.dart';

class MainNavBarController extends GetxController with WidgetsBindingObserver {
  final RxInt selectedIndex = 0.obs;
  final RxBool fabExpanded = false.obs;
  final RxBool showVoiceDialog = false.obs;
  final RxBool showAnalyzingOverlay = false.obs;
  final AudioController audioController = Get.put(AudioController());
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService notificationService = NotificationService();
  bool isAnyCameraTaskAdded = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Get.isRegistered<AudioController>()) {
      audioController.disposeResources();
      Get.delete<AudioController>();
    }
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    audioController.handleAppLifecycleChange(state);
  }

  void onTabSelected(int index) {
    selectedIndex.value = index;
    fabExpanded.value = false;
  }

  void toggleFab() {
    fabExpanded.value = !fabExpanded.value;
  }

  void closeFab() {
    fabExpanded.value = false;
  }

  Future<void> startVoiceTaskFlow(BuildContext context) async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        builder:
            (_) => WillPopScope(
              onWillPop: () async {
                Get.snackbar(
                  'Recording in progress',
                  'Please don’t close while recording is in progress',
                );
                return false;
              },
              child: VoiceRecordingBottomSheet(controller: this),
            ),
      );
      showAnalyzingOverlay.value = false;
      await audioController.startRecording();
    } else {
      Get.snackbar(
        'Permission Required',
        'Microphone permission is required to use this feature.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> stopVoiceRecordingAndAnalyze() async {
    showAnalyzingOverlay.value = true;
    await audioController.stopRecording();
    await audioController.submitVoiceTask();
    showAnalyzingOverlay.value = false;
    if (selectedIndex.value == 0 && audioController.isAnyVoiceTaskAdded) {
      final homeController = Get.find<HomeController>();
      await homeController.loadTasks();
      homeController.showSuccessFlushBar('Task added successfully');
    }
  }

  Future<void> cancelVoiceRecording() async {
    await audioController.cancelRecording();
    Get.snackbar('Recording Interrupted', 'The recording has been discarded.');
    // showVoiceDialog.value = false;
  }

  Future<Uint8List> compressCroppedImage(Uint8List croppedBytes) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithList(
        croppedBytes,
        minWidth: 600,
        minHeight: 600,
        quality: 70,
        format: CompressFormat.jpeg,
      );
      if (compressedBytes.isEmpty) {
        BotToast.showText(text: "Compression failed or returned empty bytes.");
        return Uint8List(0);
      }
      print('Compressed size: ${compressedBytes.length} bytes');
      return compressedBytes;
    } catch (e) {
      BotToast.showText(text: "Image compression failed: $e");
      return Uint8List(0);
    }
  }

  Future<void> startImageTaskFlow(BuildContext context) async {
    final now = DateTime.now();
    final picker = ImagePicker();
    isAnyCameraTaskAdded = false;
    try {
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedImage == null) return;

      final imageData = await File(pickedImage.path).readAsBytes();
      final croppedImage = await Get.to(
        FreehandImageCropper(title: "Crop Image", imagePath: imageData),
      );
      if (croppedImage == null) {
        BotToast.showText(text: 'Cropping was cancelled or failed.');
        return;
      }

      showAnalyzingOverlay.value = true;
      final compressedBytes = await compressCroppedImage(croppedImage);
      if (compressedBytes.isEmpty) {
        BotToast.showText(text: "Image compression failed.");
        return;
      }

      final tasks = await audioController.extractTasksFromImage(croppedImage);
      if (tasks.isEmpty) {
        final error =
            audioController.errorImageMessage ??
            'No tasks extracted from the image.';
        BotToast.showText(text: error);
        return;
      }

      for (final task in tasks) {
        print('📝 Task details: ${task.toMap()}');
        // if (task.dueDate != null &&
        //     task.dueDate!.isBefore(DateTime(now.year, now.month, now.day))) {
        //   Get.snackbar('Task Not Added', 'Due date is in the past');
        //   continue;
        // }
        // if (task.dueDate != null &&
        //     task.dueDate!.year == now.year &&
        //     task.dueDate!.month == now.month &&
        //     task.dueDate!.day == now.day &&
        //     task.reminderDate != null) {
        //   final reminderDateTime = DateTime(
        //     task.reminderDate!.year,
        //     task.reminderDate!.month,
        //     task.reminderDate!.day,
        //     task.reminderDate!.hour,
        //     task.reminderDate!.minute,
        //   );
        //   if (reminderDateTime.isBefore(now)) {
        //     Get.snackbar('Task Not Added', 'Reminder time is in the past');
        //     continue;
        //   }
        // }
        await _databaseHelper.insertTask(task);
        DateTime? reminderDateTime;
        if (task.dueDate != null && task.reminderDate != null) {
          reminderDateTime = DateTime(
            task.reminderDate!.year,
            task.reminderDate!.month,
            task.reminderDate!.day,
            task.reminderDate!.hour,
            task.reminderDate!.minute,
          );
        }
        isAnyCameraTaskAdded = true;
        if (task.reminder == true &&
            reminderDateTime != null &&
            reminderDateTime.isAfter(DateTime.now())) {
          await notificationService.scheduleNotification(
            id: task.id.hashCode,
            title: task.title,
            body:
                task.description.isNotEmpty
                    ? task.description
                    : 'You have a task reminder!',
            scheduledDate: reminderDateTime,
            repeatFlag: task.repeatFlag,
          );
        }
      }

      if (selectedIndex.value == 0 && isAnyCameraTaskAdded) {
        final homeController = Get.find<HomeController>();
        await homeController.loadTasks();
        homeController.showSuccessFlushBar('Task added successfully');
      }
    } catch (e) {
      BotToast.showText(text: 'An error occurred: $e');
    } finally {
      showAnalyzingOverlay.value = false;
    }
  }

  Future<void> addManualTask(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AddTaskBottomSheet(
              onAdd: ({
                required String title,
                String? notes,
                required List<SubTask> subtasks,
                required String priority,
                DateTime? dueDate,
                DateTime? reminderDate,
                bool? reminderEnabled,
                RepeatFlag? repeatFlag,
              }) async {
                {
                  final homeController = Get.find<HomeController>();
                  await homeController.loadTasks();
                  homeController.showSuccessFlushBar('Task added successfully');
                }
              },
            ),
          ),
    );
  }
}
