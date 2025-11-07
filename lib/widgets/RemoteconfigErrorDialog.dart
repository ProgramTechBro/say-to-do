import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../main.dart';
import '../services/remote_config.dart';
Future<void> showRemoteConfigErrorDialog() async {
  bool isLoading = false;

  await Get.dialog(
    StatefulBuilder(
      builder: (_, setState) {
        final screenWidth = MediaQuery.of(Get.context!).size.width;
        final screenHeight = MediaQuery.of(Get.context!).size.height;

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.06),
          ),
          child: SizedBox(
            width: screenWidth * 0.85,
            height: screenHeight * 0.22,
            child: isLoading
                ? Center(
              child: SizedBox(
                height: screenWidth * 0.08,
                width: screenWidth * 0.08,
                child: const CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                  strokeWidth: 2.5,
                ),
              ),
            )
                : Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Text(
                      "Configuration Error",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.048,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Unable to load configuration. Check your internet and retry.",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: screenWidth * 0.038,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        setState(() => isLoading = true);
                        await RemoteKeysService.initialize();
                        if (RemoteKeysService.geminiApiKey.isNotEmpty) {
                          if (!remoteConfigReady.isCompleted) {
                            remoteConfigReady.complete();
                          }
                          Get.back();
                        } else {
                          setState(() => isLoading = false);
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.03,
                          ),
                        ),
                      ),
                      child: Text(
                        "Retry",
                        style: TextStyle(
                          color: const Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.042,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
    barrierDismissible: false,
  );
}