import 'package:double_tap_to_exit/double_tap_to_exit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/OnboardingController.dart';
import '../utils/constants.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingController controller = Get.put(OnboardingController());
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final primaryColor = AppColors.primaryColor;
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    final double imageHeight = screenHeight * 0.98;
    final double horizontalPadding = screenWidth * 0.06;
    final double titleFontSize = screenWidth * 0.055;
    final double subtitleFontSize = screenWidth * 0.0382;
    final double dotActiveWidth = screenWidth * 0.06;
    final double dotInactiveWidth = screenWidth * 0.02;
    final double dotHeight = screenHeight * 0.01;
    final double nextButtonSize = screenWidth * 0.14;
    final double nextIconSize = nextButtonSize * 0.39;
    final double skipFontSize = screenWidth * 0.037;
    final double skipTop = screenHeight * 0.001;
    final double skipRight = screenWidth * 0.045;
    final double contentTop = screenHeight * 0.03;
    final double contentBottom = MediaQuery.of(context).padding.bottom + screenHeight * 0.04;

    return DoubleTapToExit(
      snackBar: SnackBar(
        content: Text(
          'Double tap to exit the app',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.04,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(screenWidth * 0.03),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
      ),
      child: WillPopScope(
          onWillPop: () async {
            if (controller.currentPage.value > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.ease,
              );
              return false;
            }
            return true;
          },
        child: Scaffold(
          backgroundColor: Color(0xFFF7F7F7),
          body: Stack(
            children: [
              SizedBox(
                height: imageHeight,
                width: screenWidth,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: controller.pages.length,
                      onPageChanged: controller.updateCurrentPage,
                      itemBuilder: (context, index) {
                        final page = controller.pages[index];
                        return Container(
                          width: screenWidth,
                          height: imageHeight,
                          color: Colors.transparent,
                          child: Image.asset(
                            page['image']!,
                            width: screenWidth,
                            height: imageHeight,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: skipTop, right: skipRight),
                          child: TextButton(
                            onPressed: controller.finishOnboarding,
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: skipFontSize,
                                fontFamily: 'Inter18',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: contentTop,
                    bottom: contentBottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(() => Text(
                        controller.pages[controller.currentPage.value]['title']!,
                        style: GoogleFonts.manrope(
                          color: Colors.black,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )),
                      SizedBox(height: screenHeight * 0.005),
                      Obx(() => Text(
                        controller.pages[controller.currentPage.value]['subtitle']!,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF4B5563),
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      )),
                      SizedBox(height: screenHeight * 0.04),
                      Obx(() {
                        bool isLastPage = controller.currentPage.value == controller.pages.length - 1;
                        return Row(
                          children: [
                            if (!isLastPage)
                              Row(
                                children: List.generate(controller.pages.length, (index) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                                    width: controller.currentPage.value == index
                                        ? dotActiveWidth
                                        : dotInactiveWidth,
                                    height: dotHeight,
                                    decoration: BoxDecoration(
                                      color: controller.currentPage.value == index
                                          ? primaryColor
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(dotHeight),
                                    ),
                                  );
                                }),
                              ),
                            if (!isLastPage) const Spacer(),
                            isLastPage
                                ? Expanded(
                              child: ElevatedButton(
                                onPressed: controller.finishOnboarding,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                                ),
                                child: Text(
                                  "Let’s Get Started!",
                                  style: GoogleFonts.manrope(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                                : GestureDetector(
                              onTap: () => controller.goToNextPage(_pageController),
                              child: Container(
                                width: nextButtonSize,
                                height: nextButtonSize,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: nextIconSize,
                                ),
                              ),
                            ),
                          ],
                        );
                      })
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}