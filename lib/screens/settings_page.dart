import 'package:first_project/utils/UrlLauncher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/LanguageScreenController.dart';
import '../utils/NativeAdWidget.dart';
import '../widgets/LanguagePickerDialog.dart';
import '../utils/constants.dart';
import 'notification_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'help_support_page.dart';
import 'about_page.dart';

class SettingsController extends GetxController {
  final LanguageScreenController languageScreenController = Get.find<LanguageScreenController>();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();
  final RxInt rating = 0.obs;
  final Rxn<XFile> attachment = Rxn<XFile>();
  final RxInt feedbackLength = 0.obs;
}

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);
  final SettingsController controller = Get.put(SettingsController());

  Future<bool> requestImagePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) return true;
      if (await Permission.photos.isGranted) return true;
      var storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) return true;
      var photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted) return true;
      return false;
    } else if (Platform.isIOS) {
      var status = await Permission.photos.request();
      return status.isGranted;
    }
    return false;
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              LanguagePickerBottomSheet(controller: controller.languageScreenController),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  void showFeedbackDialog(BuildContext context, SettingsController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: const Color(0xFFF7F7F7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: screenWidth * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: GetBuilder<SettingsController>(
              init: controller,
              builder:
                  (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Send Feedback',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'Inter18'
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 26,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Subject',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: controller.subjectController,
                        style: TextStyle(
                            fontFamily: 'Inter18'
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter subject',
                          hintStyle: TextStyle(
                              fontFamily: 'Inter18'
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Rating',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => Row(
                          children: List.generate(
                            5,
                            (i) => IconButton(
                              icon: Icon(
                                Icons.star,
                                size: 30,
                                color:
                                    i < controller.rating.value
                                        ? Colors.amber
                                        : Colors.grey[400],
                              ),
                              onPressed: () => controller.rating.value = i + 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Feedback',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          TextField(
                            controller: controller.feedbackController,
                            style: TextStyle(
                                fontFamily: 'Inter18'
                            ),
                            maxLines: 5,
                            maxLength: 500,
                            onChanged:
                                (val) =>
                                    controller.feedbackLength.value =
                                        val.length,
                            decoration: InputDecoration(
                              hintText: 'Tell us what you think...',
                              hintStyle: TextStyle(
                                fontFamily: 'Inter18'
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              counterText: '',
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 16,
                            child: Obx(
                              () => Text(
                                '${controller.feedbackLength.value}/500',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Attachment (Optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () =>
                            controller.attachment.value == null
                                ? GestureDetector(
                                  onTap: () async {
                                    bool granted =
                                        await requestImagePermission();
                                    if (granted) {
                                      final picker = ImagePicker();
                                      final picked = await picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (picked != null)
                                        controller.attachment.value = picked;
                                    } else {
                                      Get.snackbar(
                                        'Permission Denied',
                                        'Storage permission is required to pick an image.',
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: const [
                                        SizedBox(width: 12),
                                        Icon(
                                          Icons.image_outlined,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Add screenshot',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : Stack(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 100,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: Colors.white,
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(
                                              controller.attachment.value!.path,
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap:
                                            () =>
                                                controller.attachment.value =
                                                    null,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.subjectController.clear();
                                controller.feedbackController.clear();
                                controller.feedbackLength.value = 0;
                                controller.attachment.value = null;
                                controller.rating.value = 0;
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontSize: 16,fontFamily: 'Inter18'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.subjectController.clear();
                                controller.feedbackController.clear();
                                controller.feedbackLength.value = 0;
                                controller.attachment.value = null;
                                controller.rating.value = 0;
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0088FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(fontSize: 16,fontFamily: 'Inter18'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.02),
          child: Text(
            'Settings',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter18',
              fontSize: screenWidth * 0.055, // ~24
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.01,
        ),
        children: [
          // Premium Card
          // GestureDetector(
          //   onTap: (){
          //     Get.toNamed('/premium', arguments: {'fromNamed': false});
          //   },
          //   child: Container(
          //     width: double.infinity,
          //     padding: EdgeInsets.symmetric(
          //       horizontal: screenWidth * 0.05,
          //       vertical: screenHeight * 0.04,
          //     ),
          //     decoration: BoxDecoration(
          //       color: AppColors.primaryColor,
          //       borderRadius: BorderRadius.circular(screenWidth * 0.06),
          //     ),
          //     child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         SvgPicture.asset(
          //           'assets/icons/premium.svg',
          //           height: screenHeight * 0.05,
          //         ),
          //         SizedBox(width: screenWidth * 0.04),
          //         Expanded(
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Row(
          //                 children: [
          //                   Text(
          //                     'Professional',
          //                     style: TextStyle(
          //                       color: Colors.white,
          //                       fontWeight: FontWeight.bold,
          //                       fontFamily: 'Inter18',
          //                       fontSize: screenWidth * 0.055,
          //                     ),
          //                   ),
          //                   SizedBox(width: screenWidth * 0.02),
          //                   Text(
          //                     '10 / user',
          //                     style: TextStyle(
          //                       color: Colors.white,
          //                       fontSize: screenWidth * 0.04,
          //                       fontFamily: 'Inter18',
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //               SizedBox(height: screenHeight * 0.01),
          //               Row(
          //                 children: [
          //                   Icon(
          //                     Icons.circle,
          //                     size: screenWidth * 0.025,
          //                     color: const Color(0xFFFFB800),
          //                   ),
          //                   SizedBox(width: screenWidth * 0.01),
          //                   Text(
          //                     'Unlimited Tasks',
          //                     style: TextStyle(
          //                       fontSize: screenWidth * 0.026,
          //                       fontFamily: 'Inter18',
          //                       color: Colors.white,
          //                     ),
          //                   ),
          //                   SizedBox(width: screenWidth * 0.03),
          //                   Icon(
          //                     Icons.circle,
          //                     size: screenWidth * 0.025,
          //                     color: const Color(0xFFFFB800),
          //                   ),
          //                   SizedBox(width: screenWidth * 0.01),
          //                   Text(
          //                     'AI-Powered Integrations',
          //                     style: TextStyle(
          //                       fontSize: screenWidth * 0.026,
          //                       fontFamily: 'Inter18',
          //                       color: Colors.white,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SizedBox(height: screenHeight * 0.03),

          // Account Settings
          _buildSettingsContainer(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            title: 'Account Settings',
            children: [
              // _SettingsRow(
              //   svg: 'assets/icons/notification.svg',
              //   label: 'Notifications',
              //   onTap: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(builder: (_) => NotificationScreen()),
              //     );
              //   },
              //   trailing: Icon(
              //     Icons.arrow_forward_ios,
              //     size: screenWidth * 0.045,
              //     color: Colors.grey,
              //   ),
              // ),
              // Divider(
              //   height: 1,
              //   thickness: 0.5,
              //   indent: screenWidth * 0.04,
              //   endIndent: screenWidth * 0.04,
              //   color: Colors.grey[300],
              // ),
              Obx(
                () => _SettingsRow(
                  svg: 'assets/icons/language.svg',
                  label: 'Language',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.languageScreenController.selectedLanguage['title'] ??
                            'English',
                        style: TextStyle(
                          color: Color(0xFF6663F1),
                          fontWeight: FontWeight.w500,
                          fontSize: screenWidth * 0.037,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: screenWidth * 0.045,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () => _showLanguagePicker(context),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:screenWidth*0.04 ),
            child: const NativeAdWidget(isThisAdShow: true,),
          ),
          // Support
          _buildSettingsContainer(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            title: 'Support',
            children: [
              _SettingsRow(
                svg: 'assets/icons/help&support.svg',
                label: 'FAQs',
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => HelpSupportPage()));
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: screenWidth * 0.045,
                  color: Colors.grey,
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: screenWidth * 0.04,
                endIndent: screenWidth * 0.04,
                color: Colors.grey[300],
              ),
              // _SettingsRow(
              //   svg: 'assets/icons/feedback.svg',
              //   label: 'Send Feedback',
              //   onTap: () {
              //     showFeedbackDialog(context, controller);
              //   },
              //   trailing: Icon(
              //     Icons.arrow_forward_ios,
              //     size: screenWidth * 0.045,
              //     color: Colors.grey,
              //   ),
              // ),
              _SettingsRow(
                svg: 'assets/icons/privacypolicy.svg',
                label: 'Privacy Policy',
                onTap: () {
                  urlLauncher(AppConstants.privacyPolicyLink);
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: screenWidth * 0.045,
                  color: Colors.grey,
                ),
                svgColor: Color(0xFF9CA3AF),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: screenWidth * 0.04,
                endIndent: screenWidth * 0.04,
                color: Colors.grey[300],
              ),
              _SettingsRow(
                svg: 'assets/icons/termcondition.svg',
                label: 'Terms and Conditions',
                onTap: () {
                  urlLauncher(AppConstants.termsConditionsLink);
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: screenWidth * 0.045,
                  color: Colors.grey,
                ),
                svgColor: Color(0xFF9CA3AF),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                indent: screenWidth * 0.04,
                endIndent: screenWidth * 0.04,
                color: Colors.grey[300],
              ),
              _SettingsRow(
                svg: 'assets/icons/about.svg',
                label: 'About',
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => AboutPage()));
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: screenWidth * 0.045,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.04),

          Center(
            child: Text(
              'TaskMate v1.0.0',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: screenWidth * 0.035,
                fontFamily: 'Inter18'
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContainer({
    required double screenWidth,
    required double screenHeight,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              screenWidth * 0.04,
              screenHeight * 0.02,
              screenWidth * 0.04,
              screenHeight * 0.01,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.045,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String svg;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? svgColor;

  const _SettingsRow({
    required this.svg,
    required this.label,
    this.trailing,
    required this.onTap,
    this.svgColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenWidth * 0.03,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                svg,
                height: screenWidth * 0.06,
                width: screenWidth * 0.06,
                color: svgColor,
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.041,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                    fontFamily: 'Inter18'
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
