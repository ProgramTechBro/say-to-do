import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

Future<bool> checkInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none)) {
    // Get.snackbar(
    //   'No Internet',
    //   'No internet connection. Please connect and try again.',
    // );
    return false;
  }
  return true;
}