import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:first_project/services/dio_Service.dart';
import 'package:first_project/services/notification_service.dart';
import 'package:first_project/services/remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../Enum/RepeatFlag.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../utils/NoInternet.dart';
import '../utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'LanguageScreenController.dart';

class AudioController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final LanguageScreenController controller =
      Get.find<LanguageScreenController>();

  bool isRecording = false;
  bool isPlaying = false;
  double buttonSize = 40.0;
  String? audioPath;
  String? recordedAudioPath;
  bool isAnyVoiceTaskAdded = false;


  RxString userText = ''.obs;
  RxBool hasTranscription = false.obs;
  RxBool isLoading = false.obs;

  String? errorMessage;
  String? errorImageMessage;

  @override
  void onInit() {
    super.onInit();
  }
  /// Manually stop recording and dispose resources
  void disposeResources() {
    try {
      if (isRecording) {
        Recorder.instance.stopRecording();
        isRecording = false;
        buttonSize = 40.0;
        update(['recording']);
      }
      Recorder.instance.stop();
    } catch (e) {
      print('Error disposing audio resources: $e');
    }
  }

  /// Handle app lifecycle changes
  void handleAppLifecycleChange(AppLifecycleState state) {
    print('App state changed to: $state');
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      disposeResources();
    }
  }
  Future<void> startRecording() async {
    try {
      if (isRecording) return; // Already recording

      final granted = await Permission.microphone.request().isGranted;
      if (!granted) {
        BotToast.showText(text: 'Microphone permission is required');
        return;
      }

      Directory tempDir = await getTemporaryDirectory();
      audioPath =
          '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}_audio.m4a';

      await Recorder.instance.init();
      Recorder.instance.start();
      Recorder.instance.startRecording(completeFilePath: audioPath!);

      isRecording = true;
      buttonSize = 50.0;
      update(['recording']);
      print('🎙️ Recording started: $audioPath');
    } catch (e) {
      print('Error starting recording: $e');
      BotToast.showText(text: 'Error starting recording');
    }
  }

  Future<void> stopRecording() async {
    try {
      if (!isRecording) return; // Already stopped

      isRecording = false;
      buttonSize = 40.0;

      Recorder.instance.stopRecording();
      recordedAudioPath = audioPath;

      update(['recording']);

      // if (recordedAudioPath != null) {
      //   // BotToast.showText(text: '🎧 Recording saved');
      // } else {
      //   BotToast.showText(text: 'Recording failed');
      // }
    } catch (e) {
      print('Error stopping recording: $e');
      BotToast.showText(text: 'Error stopping recording');
    }
  }

  void deleteRecording() {
    recordedAudioPath = null;
    userText.value = '';
    hasTranscription.value = false;
    update(['recording']);
  }

  Future<void> cancelRecording() async {
    try {
      if (isRecording) {
        await stopRecording();
        isRecording = false;
        buttonSize = 40.0;
        update(['recording']);
      }
      if (audioPath != null) {
        final file = File(audioPath!);
        if (await file.exists()) {
          await file.delete();
          print('Deleted recording file: $audioPath');
        }
        audioPath = null;
        recordedAudioPath = null;
      }
    } catch (e) {
      print('Error canceling recording: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel recording.',
      );
    }
  }

  Future<void> submitVoiceTask() async {
    isAnyVoiceTaskAdded = false;
    final now = DateTime.now();
    final NotificationService notificationService = NotificationService();
    if (recordedAudioPath == null) {
      BotToast.showText(text: 'No recording found');
      return;
    }
    isLoading.value = true;
    try {
      final file = File(recordedAudioPath!);
      final tasks = await extractTasksFromAudio(file);
      if (errorMessage != null) {
        BotToast.showText(text: errorMessage!);
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
        await _databaseHelper.insertTask(task);
        isAnyVoiceTaskAdded = true;
        if (task.reminder == true &&
            reminderDateTime != null &&
            reminderDateTime.isAfter(now)) {
          await notificationService.scheduleNotification(
            id: task.id.hashCode,
            title: task.title,
            body: task.description.isNotEmpty
                ? task.description
                : 'You have a task reminder!',
            scheduledDate: reminderDateTime,
            repeatFlag: task.repeatFlag
          );
        }
      }
      // BotToast.showText(text: 'Added ${tasks.length} task(s)');
    } catch (e) {
      BotToast.showText(text: 'Failed to process voice task');
    } finally {
      deleteRecording();
      isLoading.value = false;
    }
  }



  /// Extract tasks from Voice using Gemini API
  Future<List<Task>> extractTasksFromAudio(File audioFile) async {
    errorMessage = null;
    if (!await checkInternetConnection()) {
      errorMessage = 'No internet connection. Please connect and try again.';
      return [];
    }
    final apiKey = RemoteKeysService.geminiApiKey;
    if(apiKey.isEmpty){
      errorMessage = 'Api Key Missing — Please check your internet or restart the app.';
      return [];
    }
    print('The Selected Language is  ${controller.selectedLanguage['title']}');
    print(
      'The Selected Language code is ${controller.selectedLanguage['code']}',
    );
    final endpoint =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';
    final prompt = '''
You are a task extraction assistant. Carefully listen to this audio and extract task objects in the following language only:

Language: ${controller.selectedLanguage['title']}
Code: ${controller.selectedLanguage['code']}

Each task must follow this format:
{
  "title": string (required) → very short (3–4 words),
  "description": string (required) → 1-sentence summary of the task,
  "priority": int (optional — include only if explicitly mentioned, values: 1 = Low, 2 = Medium, 3 = High),
  "dueDate": string (optional — in ISO 8601 format),
  "subtasks": array of strings (optional — if user mentions subtasks, e.g. ["Buy milk", "Call John"]),
  "reminder": boolean (optional — true if user says 'remind me' or similar),
  "reminderDate": string (optional — in ISO 8601 format, if user says a specific reminder time),
  "createdAt": string (required — leave empty/null; system will auto-fill with current time)
  "repeatFlag": string (optional → include only if explicitly mentioned, values: "Once", "Daily", "Weekly", "Monthly", default to "Once" if not mentioned)
}

 STRICT RULES:
 - Return ONLY a pure JSON array, e.g. [{"title":"...", "createdAt":"..."}]
 - DO NOT use code blocks or backticks
 - DO NOT add any text, labels, or explanation
 - Omit any field not clearly mentioned in user input
 - A date MUST be placed inside the correct task if it is mentioned
 - If user mentions subtasks, extract them as a list of short strings in the 'subtasks' field
 - Only set "reminder": true if the user explicitly says "remind me", "set a reminder", or a clearly similar phrase
 - If the user only mentions a reminder time (e.g., "at 6 PM", "tomorrow morning") without asking for a reminder, extract it as "reminderDate" but keep "reminder": false
 - 'dueDate' is the task deadline, and 'reminderDate' is the reminder time 
 - Keep the title extremely short (3–4 words), summarizing the main goal of the task
 - If user mentions a repeat frequency (e.g., "daily", "weekly"), set "repeatFlag" to "Daily", "Weekly", etc.
 - If no repeat frequency is mentioned, set "repeatFlag" to "Once"
 - Rephrase the user's task sentence into a clean, short, and professional description in the SAME language specified above
 - If the user does not mention a due date, keep "dueDate": null
 - If the user only mentions day and month (like "25 Aug") in the due date and does not mention the year, then add the current year (${DateTime.now().year}).
 - The returned text MUST be fully in ${controller.selectedLanguage['title']} (${controller.selectedLanguage['code']})
 - If the audio contains no clear task or is silent, return an empty array [] without explanation.
 - If the audio is silent, contains noise, or has no discernible words or task, return exactly [] (an empty JSON array) with no other content. Do not guess. Do not fabricate any task. Do not assume intent. Return an empty array [].
''';

    try {
      final dio = DioService().client;
      final bytes = await audioFile.readAsBytes();
      final encoded = base64Encode(bytes);

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inlineData": {"mimeType": "audio/m4a", "data": encoded},
              },
            ],
          },
        ],
      };

      final response = await dio.post(
        endpoint,
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      String raw =
          response.data['candidates'][0]['content']['parts'][0]['text'].trim();
      raw = raw.replaceAll(RegExp(r'```(\w+)?'), '').trim();

      final start = raw.indexOf('[');
      final end = raw.lastIndexOf(']');
      if (start == -1 || end == -1 || end <= start) {
        errorMessage = 'Gemini did not return a valid JSON array.';
        return [];
      }

      final jsonString = raw.substring(start, end + 1);

      List<dynamic> decoded;
      try {
        decoded = jsonDecode(jsonString);
      } catch (e) {
        errorMessage = 'Failed to parse tasks JSON.';
        print('❌ JSON Decode Error: $e\nRaw: $jsonString');
        return [];
      }

      final now = DateTime.now().toIso8601String();
      final nowDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      final tasks =
          decoded
              .map((item) {
                try {
                  item['id'] = const Uuid().v4();
                  item['createdAt'] ??= now;
                  if (![1, 2, 3].contains(item['priority'])) {
                    item['priority'] = item['dueDate'] == null ? 3 : 1;
                  }
                  item['dueDate'] ??= nowDate;
                  // if (item['dueDate'] != null) {
                  //   print('the due date is ${item['dueDate']}');
                  //   item['dueDate'] = fixDueDateYear(item['dueDate'])?.toIso8601String();
                  // } else {
                  //   item['dueDate'] = nowDate;
                  // }
                  print('the due date is ${item['dueDate']}');
                  item['repeatFlag'] ??= 'Once';
                  item['repeatFlag'] = {
                    'Once': RepeatFlag.Once,
                    'Daily': RepeatFlag.Daily,
                    'Weekly': RepeatFlag.Weekly,
                    'Monthly': RepeatFlag.Monthly,
                  }[item['repeatFlag']] ?? RepeatFlag.Once;
                  if (item['subtasks'] != null && item['subtasks'] is List) {
                    item['subtasks'] = jsonEncode(
                      (item['subtasks'] as List)
                          .map((s) => {'title': s, 'isCompleted': false})
                          .toList(),
                    );
                  }
                  // Handle reminder: ensure boolean
                  if (item['reminder'] != null) {
                    item['reminder'] =
                        item['reminder'] == true || item['reminder'] == 1;
                  }
                  // Handle reminderDate: pass as is (should be ISO string)
                  return Task.fromMap(item);
                } catch (err) {
                  print('Skipping malformed task: $item\nError: $err');
                  return null;
                }
              })
              .whereType<Task>()
              .toList();

      if (tasks.isEmpty) {
        errorMessage = 'No valid tasks found in audio.';
      }

      return tasks;
    } on DioException catch (dioError) {
      print('Response: ${dioError.response}');
      String message = 'Something went wrong.';

      if (dioError.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timed out.';
      } else if (dioError.type == DioExceptionType.sendTimeout) {
        message = 'Send request timed out.';
      } else if (dioError.type == DioExceptionType.receiveTimeout) {
        message = 'Receive timeout occurred.';
      } else if (dioError.type == DioExceptionType.badResponse) {
        final statusCode = dioError.response?.statusCode;
        if (statusCode == 503) {
          message = 'Server is overloaded or unavailable.Try again later.';
        } else if (statusCode == 429) {
          message = 'Rate limit exceeded. Please wait before trying again.';
        } else {
          message = 'Server responded with error: $statusCode';
        }
      } else if (dioError.type == DioExceptionType.cancel) {
        message = 'Request was cancelled.';
      } else if (dioError.type == DioExceptionType.unknown) {
        message = 'An unknown network error occurred.';
      }

      errorMessage = message;
      print('❌ Dio error: ${dioError.message}');
      return [];
    } catch (e) {
      errorMessage = 'Unexpected error while processing audio.';
      print('❌ Unexpected error: $e');
      return [];
    }
  }

  /// Extract tasks from an image using Gemini API
  Future<List<Task>> extractTasksFromImage(Uint8List imageBytes) async {
    errorImageMessage = null;
    if (!await checkInternetConnection()) {
      errorImageMessage = 'No internet connection. Please connect and try again.';
      return [];
    }
    final apiKey = RemoteKeysService.geminiApiKey;
    if(apiKey.isEmpty){
      errorImageMessage = 'Api Key Missing — Please check your internet or restart the app.';
      return [];
    }
    print('The Selected Language is   ${controller.selectedLanguage['title']}');
    print(
      'The Selected Language code is ${controller.selectedLanguage['code']}',
    );
    final modelName = 'gemini-2.5-flash';
    final endpoint =
        'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey';
    final prompt = '''
You are a task extraction assistant. Carefully analyze this image (photo, handwritten note, screenshot, etc.) and extract task objects in the following language only:

Language: ${controller.selectedLanguage['title']}
Code: ${controller.selectedLanguage['code']}

Each task must follow this format:
{
  "title": string (required) → 12 very short (3–124 words),
  "description": string (required) → 12 1-sentence summary of the task,
  "priority": int (optional → include only if explicitly mentioned, values: 1 = Low, 2 = Medium, 3 = High),
  "dueDate": string (optional → in ISO 8601 format),
  "subtasks": array of strings (optional → if user mentions subtasks, e.g. ["Buy milk", "Call John"]),
  "reminder": boolean (optional → true if user says 'remind me' or similar),
  "reminderDate": string (optional → in ISO 8601 format, if user says a specific reminder time),
  "createdAt": string (required → leave empty/null; system will auto-fill with current time)
  "repeatFlag": string (optional → include only if explicitly mentioned, values: "Once", "Daily", "Weekly", "Monthly", default to "Once" if not mentioned)
}

 STRICT RULES:
 - Return ONLY a pure JSON array, e.g. [{"title":"...", "createdAt":"..."}]
 - DO NOT use code blocks or backticks
 - DO NOT add any text, labels, or explanation
 - Omit any field not clearly mentioned in user input
 - A date MUST be placed inside the correct task if it is mentioned
 - If user mentions subtasks, extract them as a list of short strings in the 'subtasks' field
 - Only set "reminder": true if the user explicitly says "remind me", "set a reminder", or a clearly similar phrase
 - If the user only mentions a reminder time (e.g., "at 6 PM", "tomorrow morning") without asking for a reminder, extract it as "reminderDate" but keep "reminder": false
 - 'dueDate' is the task deadline, and 'reminderDate' is the reminder time 
 - Keep the title extremely short (3–124 words), summarizing the main goal of the task
 - Rephrase the user's task sentence into a clean, short, and professional description in the SAME language specified above
 - If user mentions a repeat frequency (e.g., "daily", "weekly"), set "repeatFlag" to "Daily", "Weekly", etc.
 - If no repeat frequency is mentioned, set "repeatFlag" to "Once"
 - If the user does not mention a due date, keep "dueDate": null
 - If the user only mentions day and month (like "25 Aug") in the due date and does not mention the year, then add the current year (${DateTime.now().year}).
 - The returned text MUST be fully in ${controller.selectedLanguage['title']} (${controller.selectedLanguage['code']})
 - If the image contains no text or is an empty or random image with no meaningful content, do not add any task and return an empty array [] without explanation.
''';

    try {
      final dio = DioService().client;
      final encoded = base64Encode(imageBytes);
      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inlineData": {"mimeType": "image/jpeg", "data": encoded},
              },
            ],
          },
        ],
      };

      final response = await dio.post(
        endpoint,
        data: jsonEncode(body),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      String raw =
          response.data['candidates'][0]['content']['parts'][0]['text'].trim();
      raw = raw.replaceAll(RegExp(r'```(\w+)?'), '').trim();

      final start = raw.indexOf('[');
      final end = raw.lastIndexOf(']');
      if (start == -1 || end == -1 || end <= start) {
        errorImageMessage = 'Gemini did not return a valid JSON array.';
        return [];
      }

      final jsonString = raw.substring(start, end + 1);

      List<dynamic> decoded;
      try {
        decoded = jsonDecode(jsonString);
      } catch (e) {
        errorImageMessage = 'Failed to parse tasks JSON.';
        print('❌ JSON Decode Error: $e\nRaw: $jsonString');
        return [];
      }

      final now = DateTime.now().toIso8601String();
      final nowDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      final tasks =
          decoded
              .map((item) {
                try {
                  item['id'] = const Uuid().v4();
                  item['createdAt'] ??= now;
                  if (![1, 2, 3].contains(item['priority'])) {
                    item['priority'] = item['dueDate'] == null ? 3 : 1;
                  }
                  item['dueDate'] ??= nowDate;
                  item['repeatFlag'] ??= 'Once';
                  item['repeatFlag'] = {
                    'Once': RepeatFlag.Once,
                    'Daily': RepeatFlag.Daily,
                    'Weekly': RepeatFlag.Weekly,
                    'Monthly': RepeatFlag.Monthly,
                  }[item['repeatFlag']] ?? RepeatFlag.Once;
                  if (item['subtasks'] != null && item['subtasks'] is List) {
                    item['subtasks'] = jsonEncode(
                      (item['subtasks'] as List)
                          .map((s) => {'title': s, 'isCompleted': false})
                          .toList(),
                    );
                  }
                  // Handle reminder: ensure boolean
                  if (item['reminder'] != null) {
                    item['reminder'] =
                        item['reminder'] == true || item['reminder'] == 1;
                  }
                  // Handle reminderDate: pass as is (should be ISO string)
                  return Task.fromMap(item);
                } catch (err) {
                  print('Skipping malformed task: $item\nError: $err');
                  return null;
                }
              })
              .whereType<Task>()
              .toList();

      if (tasks.isEmpty) {
        errorImageMessage = 'No valid tasks found in image.';
      }

      return tasks;
    } on DioException catch (dioError) {
      print('Response: ${dioError.response}');
      String message = 'Something went wrong.';
      if (dioError.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timed out.';
      } else if (dioError.type == DioExceptionType.sendTimeout) {
        message = 'Send timeout.';
      } else if (dioError.type == DioExceptionType.receiveTimeout) {
        message = 'Receive timeout.';
      } else if (dioError.type == DioExceptionType.badResponse) {
        message = 'Bad response from server.';
      }
      errorImageMessage = message;
      return [];
    } catch (e) {
      errorImageMessage = 'Failed to process image task.';
      print('Error: $e');
      return [];
    }
  }
  // DateTime? fixDueDateYear(dynamic dueDate) {
  //   final now = DateTime.now();
  //   final currentYear = now.year;
  //   try {
  //     if (dueDate == null) return null;
  //     if (dueDate is DateTime) {
  //       return dueDate;
  //     }
  //     if (dueDate is String) {
  //       try {
  //         final parsed = DateTime.parse(dueDate);
  //         return parsed;
  //       } catch (_) {}
  //       try {
  //         final parsedLong = DateFormat('d MMMM').parseStrict(dueDate);
  //         return DateTime(currentYear, parsedLong.month, parsedLong.day);
  //       } catch (_) {}
  //
  //       try {
  //         final parsedShort = DateFormat('d MMM').parseStrict(dueDate);
  //         return DateTime(currentYear, parsedShort.month, parsedShort.day);
  //       } catch (_) {}
  //     }
  //   } catch (e) {
  //     print('⚠️ Error fixing dueDate year: $e');
  //   }
  //
  //   return null;
  // }
}
