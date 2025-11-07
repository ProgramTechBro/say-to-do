import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/services/AdService.dart';
import 'package:first_project/services/Consent_Services.dart';
import 'package:first_project/services/dio_Service.dart';
import 'package:first_project/services/remote_config.dart';
import 'package:first_project/utils/AdHelper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'controllers/LanguageScreenController.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/constants.dart';
import 'package:first_project/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_project/screens/main_nav_bar_page.dart';
import 'screens/language_selection_screen.dart';
import 'screens/premium_screen.dart';
Future<void> loadAppOpenAd({
  void Function(AppOpenAd)? onAdShowedFullScreenContent,
  void Function(AppOpenAd)? onAdDismissedFullScreenContent,
}) async {
  ///Will Uncomment When Remote Config
  // bool isAdsEnabled = GetStorage().read(AppKeys.showAds) ?? true;
  // if (isAdsEnabled) {
    AppOpenAd.load(
      adUnitId: AdHelper.openAppAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: onAdShowedFullScreenContent ?? (ad) {},
            onAdDismissedFullScreenContent: (ad) {
              onAdDismissedFullScreenContent?.call(ad);
              ad.dispose();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
//}
//late Completer<void> remoteConfigReady;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //remoteConfigReady = Completer<void>();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await GetStorage.init();
  DioService();
  await RemoteKeysService.initialize();
  // Get.put<AdCheckService>(AdCheckService(), permanent: true);
  // Get.put(PremiumController(), permanent: true);
  await NotificationService().init();
  ConsentService.askConsent();
  Get.put<AdService>(AdService(), permanent: true);
  Get.put(LanguageScreenController(), permanent: true);
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;
  const MyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/language', page: () => const LanguageSelectionScreen()),
        // GetPage(name: '/premium', page: () => PremiumView()),
        GetPage(name: '/main', page: () => const MainNavBarScreen()),
      ],
    );
  }
}

