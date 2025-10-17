import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    navigateNext();
  }

  Future<void> navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    final languageSelected = prefs.getBool('language_selected') ?? false;

    if (!onboardingComplete) {
      Get.offAllNamed('/onboarding');
    } else if (!languageSelected) {
      Get.offAllNamed('/language');
    } else {
      // Get.offAllNamed('/premium', arguments: {'fromNamed': true});
      Get.offAllNamed('/main');
    }
  }
}