import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'AdService.dart';
class ConsentService extends GetxController {
  static void askConsent() {
    final params = ConsentRequestParameters(
      consentDebugSettings: ConsentDebugSettings(
        debugGeography: DebugGeography.debugGeographyEea,
        // testIdentifiers: ['8298242746D3D8164F283C64A9C3EFDE'],
      ),
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
          () async {
        if (await ConsentInformation.instance.canRequestAds()) {
          _initializeMobileAdsSDK();
        } else {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            loadForm();
          } else {
            _initializeMobileAdsSDK();
          }
        }
      },
          (FormError error) {
        // Handle the error
        _initializeMobileAdsSDK();
      },
    );
  }

  static void loadForm() {
    ConsentForm.loadAndShowConsentFormIfRequired((loadAndShowError) {
      if (loadAndShowError != null) {
      }
      _initializeMobileAdsSDK();
    });
  }

  static Future<void> _initializeMobileAdsSDK() async {
    final canRequestAds = await ConsentInformation.instance.canRequestAds();
    if (canRequestAds) {
      MobileAds.instance
        ..initialize()
        ..updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: <String>[
              '8298242746D3D8164F283C64A9C3EFDE',
            ],
          ),
        );
      // TODO: Request an ad.
      final adService = Get.find<AdService>();
      adService.showInterstitialAd();
    }
  }
}
