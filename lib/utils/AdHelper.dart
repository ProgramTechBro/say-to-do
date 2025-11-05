import 'package:flutter/foundation.dart';
class AdHelper {
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else {
      return 'ca-app-pub-5526877101369367/2890410929';
    }
  }

  static String get openAppAdId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/3419835294';
    } else {
      return 'ca-app-pub-5526877101369367/5454022755';
    }
  }

  static String get nativeAddUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else {
      return 'ca-app-pub-5526877101369367/8184127874';
    }
  }

  static String get bannerAddUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else {
      return 'ca-app-pub-5526877101369367/4811218442';
    }
  }
}
