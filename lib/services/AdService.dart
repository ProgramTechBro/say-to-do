import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/AdHelper.dart';
import '../utils/constants.dart';
enum AdLoadState { loading, loaded, failed }
const int maxFailedLoadAttempts = 2;
class AdService extends GetxController {
  RewardedAd? rewardedAd;
  BannerAd? bannerAd;
  BannerAd? bannerAdForProfile;
  BannerAd? bannerAdForFraming;
  BannerAd? bannerAdForEditing;
  NativeAd? nativeAd;
  bool nativeAdIsLoaded = false;
  InterstitialAd? interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  bool isInterstitialAdLoading=false;
  var isBannerAdLoaded=AdLoadState.loading.obs;
  var isBannerAnalyticAdLoaded=AdLoadState.loading.obs;
  bool isShowingAd = false;
  ///Will Uncomment When Remote Config
  // void refreshAdsEnabledStatus() {
  //   final updatedValue = GetStorage().read(AppKeys.showAds);
  //   if (updatedValue != null) {
  //     isAdsEnabled = updatedValue;
  //     print('isAdsEnabled updated to: $isAdsEnabled');
  //   } else {
  //     print('AppKeys.showAds not found in storage. Keeping existing value: $isAdsEnabled');
  //   }
  // }
  Future createInterstitialAd() async {
    try {
      if(isInterstitialAdLoading) return;
      isInterstitialAdLoading=true;
      return await InterstitialAd.load(
        //adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            isInterstitialAdLoading=false;
            interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            interstitialAd = null;
            isInterstitialAdLoading=false;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ),
      );
    } catch (e) {
      print('Error loading interstitial ad: $e');
      return null;
    }
  }

  Future<bool> showInterstitialAd({
    void Function(InterstitialAd)? onAdDismissedFullScreenContent,
    void Function(InterstitialAd, AdError)? onAdFailedToShowFullScreenContent,
    VoidCallback? onFinished,
  }) async {
    if (isShowingAd) {
      BotToast.showText(text: 'Ad is preparing, please wait...');
      return false;
    }
    if (interstitialAd == null) {
      print('Ad not loaded yet, skipping...');
      onFinished?.call();
      await createInterstitialAd();
      return false;
    }
    isShowingAd = true;
    final cancelLoader = BotToast.showLoading();
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print('Ad shown: $ad');
        cancelLoader();
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('Ad dismissed: $ad');
        ad.dispose();
        interstitialAd = null;
        isShowingAd = false;
        cancelLoader();
        onAdDismissedFullScreenContent?.call(ad);
        onFinished?.call();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('Ad failed to show: $error');
        ad.dispose();
        interstitialAd = null;
        isShowingAd = false;
        cancelLoader();
        onAdFailedToShowFullScreenContent?.call(ad, error);
        onFinished?.call();
        createInterstitialAd();
      },
    );
    try {
      await interstitialAd!.show();
    } catch (e) {
      print('Exception while showing ad: $e');
      interstitialAd?.dispose();
      interstitialAd = null;
      isShowingAd = false;
      cancelLoader();
      onFinished?.call();
      await createInterstitialAd();
    }
    return true;
  }

  void loadBannerAd({
    required Function(BannerAd ad) onAdLoaded,
    required Function onAdFailed,
  }) {
    final bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAddUnitId,
      size: AdSize.largeBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          onAdLoaded(ad as BannerAd);
          print('Banner Ad Loaded for ${AdHelper.bannerAddUnitId}');
        },
        onAdFailedToLoad: (ad, error) {
          onAdFailed();
          print('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );
    bannerAd.load();
  }

  void loadCalendarScreenBannerAd() {
    ///Will Uncomment
    // if (!ConsentService.canShowAds.value ||
    //     !AdCheckService.isAdShowToUser.value ||
    //     !isAdsEnabled) {
    //   isTopicAdLoaded.value = AdLoadState.disabled;
    //   return;
    // }
    // isTopicAdLoaded.value = AdLoadState.loading;
    loadBannerAd(
      onAdLoaded: (ad) {
        bannerAdForEditing = ad;
        isBannerAdLoaded.value=AdLoadState.loaded;
      },
      onAdFailed: () {
        isBannerAdLoaded.value=AdLoadState.failed;
      },
    );
  }
  void loadAnalyticsScreenBannerAd() {
    ///Will Uncomment
    // if (!ConsentService.canShowAds.value ||
    //     !AdCheckService.isAdShowToUser.value ||
    //     !isAdsEnabled) {
    //   isTopicAdLoaded.value = AdLoadState.disabled;
    //   return;
    // }
    // isTopicAdLoaded.value = AdLoadState.loading;
    loadBannerAd(
      onAdLoaded: (ad) {
        bannerAdForFraming = ad;
        isBannerAnalyticAdLoaded.value=AdLoadState.loaded;
      },
      onAdFailed: () {
        isBannerAnalyticAdLoaded.value=AdLoadState.failed;
      },
    );
  }

  Widget showBannerAd(AdLoadState state, BannerAd? ad) {
    switch (state) {
      case AdLoadState.loading:
        return const Center(child: Text('Ad is loading...'));
      case AdLoadState.failed:
        return SizedBox();
      case AdLoadState.loaded:
        if (ad == null) return const SizedBox.shrink();
        return Center(
          child: Container(
            alignment: Alignment.center,
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        );
    }
  }



  /// Loads a native ad.
  void loadNativeAd() {
    ///Will UnComment When Remote Config
    // if (!isAdsEnabled) {
    //   return;
    // } else {
      nativeAd = NativeAd(
        adUnitId: AdHelper.nativeAddUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('$NativeAd native ad loaded.');
            nativeAdIsLoaded = true;
            update();
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('$NativeAd failed To Load: $error');
            ad.dispose();
          },
        ),
        nativeAdOptions: NativeAdOptions(
          adChoicesPlacement: AdChoicesPlacement.bottomLeftCorner,
          mediaAspectRatio: MediaAspectRatio.portrait,
          videoOptions: VideoOptions(
            clickToExpandRequested: true,
            customControlsRequested: true,
            startMuted: true,
          ),
          //shouldRequestMultipleImages: true,
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
          // Required: Choose a template.
          templateType: TemplateType.medium,
          // Optional: Customize the ad's style.
          mainBackgroundColor: Colors.transparent,
          cornerRadius: 25.0,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: const Color(0xff109d58),
            style: NativeTemplateFontStyle.bold,
            size: 16,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: AppColors.secondaryColor,
            backgroundColor: Colors.white,
            style: NativeTemplateFontStyle.normal,
            size: 18,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: AppColors.secondaryColor,
            backgroundColor: Colors.white,
            style: NativeTemplateFontStyle.normal,
            size: 16,
          ),
          tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: AppColors.secondaryColor,
            backgroundColor: Colors.white,
            style: NativeTemplateFontStyle.normal,
            size: 15,
          ),
        ),
      )..load();
    }
}
