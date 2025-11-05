import 'package:first_project/screens/premium_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PremiumController.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    navigateNext();
    // initPremiumTasks();
  }

  // Future<void> initPremiumTasks() async {
  //   await Future.wait([
  //     PremiumController.to.initSubscription(),
  //     PremiumController.to.restorePurchases(false),
  //     PremiumController.to.checkSubscriptionStatus(),
  //   ]);
  // }

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
      // if(PremiumController.to.isValidSubscription()){
      //   Get.offAllNamed('/main');
      // }
      // else{
      //   Get.off(() => PremiumView(showSkip: true,));
      // }
    }
  }
}