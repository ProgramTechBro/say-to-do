import 'package:get/get.dart';
class PremiumController extends GetxController {
  RxInt selectedPlan = 2.obs;

  void selectPlan(int plan) {
    selectedPlan.value = plan;
  }
}
