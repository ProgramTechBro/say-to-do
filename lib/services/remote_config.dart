import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteKeysService {
  static String geminiApiKey = "";

  static Future<void> initialize() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 20),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await remoteConfig.fetchAndActivate();


      geminiApiKey = remoteConfig.getString('gemini_api_key');


      print("Remote Keys Loaded Successfully");
    } catch (e) {
      print("Remote Keys Load Failed: $e");
    }
  }
}
