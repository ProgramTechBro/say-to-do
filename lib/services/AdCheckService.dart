import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdCheckService extends GetxService {
  static const String _adShowKey = 'isAdShowToUser';
  static RxBool isAdShowToUser = true.obs;

  void onInIt() async {
    super.onInit();
    refreshAdStatus();
  }

  Future<void> refreshAdStatus() async {
    print('----------Refreshing Ad Service Check--------------');
    final prefs = await SharedPreferences.getInstance();
    bool isPro = prefs.getBool("isProUser") ?? false;
    String? expiryString = prefs.getString("expiryDate");

    if (isPro && expiryString != null) {
      final expiryDate = DateTime.tryParse(expiryString);
      final isStillValid = expiryDate != null && expiryDate.isAfter(DateTime.now());

      isAdShowToUser.value = !isStillValid;
      await prefs.setBool(_adShowKey, !isStillValid);
    } else {
      isAdShowToUser.value = true;
      await prefs.setBool(_adShowKey, true);
    }
  }
}
