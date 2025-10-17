import 'package:first_project/services/dio_Service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'controllers/LanguageScreenController.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/constants.dart';
import 'package:first_project/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_project/screens/main_nav_bar_page.dart';
import 'screens/language_selection_screen.dart';
import 'screens/premium_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  DioService();
  await NotificationService().init();
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
        GetPage(name: '/premium', page: () => PremiumScreen()),
        GetPage(name: '/main', page: () => const MainNavBarScreen()),
      ],
    );
  }
}

