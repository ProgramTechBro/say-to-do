import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/AdService.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  final List<Map<String, String>> pages = [
    {
      'image': 'assets/icons/onboarding_1.png',
      'title': 'Speak, Don’t Type',
      'subtitle': 'Whether you\'re walking, driving, or busy, simply speak to add your to-dos',
    },
    {
      'image': 'assets/icons/onboarding_2.png',
      'title': 'Voice-to Reminder',
      'subtitle': 'Just say, "Remind me to call Mom at 7 PM," and AI handles the rest.',
    },
    {
      'image': 'assets/icons/onboarding_3.png',
      'title': 'Watch Your Progress Grow',
      'subtitle': 'Tasks 100; Stress 0, Success 100, You made my day.',
    },
    // {
    //   'image': 'assets/icons/onboarding_4.png',
    //   'title': 'WOW',
    //   'subtitle': 'Tasks 100; Stress 0, Success 100, You made my day.',
    // },
  ];
  final adService = Get.find<AdService>();
  @override
  void onInit() {
    super.onInit();
    _markOnboardingSeen();
  }

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  Future<void> finishOnboarding() async {
    showAdThenNavigate();
  }
  void showAdThenNavigate() {
    ///Will Uncomment When Subscription
    // if (!AdCheckService.isAdShowToUser.value) {
    //   navigateBasedOnFirstTime();
    //   return;
    // }
    // If ads can be shown and interstitial is loaded
    if (adService.interstitialAd != null) {
      adService.showInterstitialAd(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          navigateBasedOnFirstTime();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          navigateBasedOnFirstTime();
        },
      );
    } else {
      navigateBasedOnFirstTime();
    }
  }

  void navigateBasedOnFirstTime() {
    Get.offAllNamed('/language');
  }

  void updateCurrentPage(int index) {
    currentPage.value = index;
  }

  void goToNextPage(PageController pageController) {
    if (currentPage.value == pages.length - 1) {
      finishOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    }
  }
}