import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'AdHelper.dart';
import 'constants.dart';
class NativeAdWidget extends StatefulWidget {
  final bool isThisAdShow;
  const NativeAdWidget({super.key, this.isThisAdShow = false});

  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _adFailedToLoad = false;
  bool _shouldShowAds = true;

  @override
  void initState() {
    super.initState();
    if(widget.isThisAdShow){
      _loadNativeAd();
    }
    ///Will Uncomment when remote Config
    // else{
    //   _shouldShowAds = GetStorage().read(AppKeys.showAds) ?? true;
    //   if (_shouldShowAds) {
    //     _loadNativeAd();
    //   } else {
    //     _adFailedToLoad = true;
    //   }
    // }
  }

  void _loadNativeAd() {
    _nativeAd?.dispose();
    _nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAddUnitId,
      //adUnitId: 'ca-app-pub-3940256099942544/2247696110',
      factoryId: 'nativeAdItem',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Failed to load the ad: ${error.message}');
          setState(() {
            _adFailedToLoad=true;
          });
        },
      ),
      nativeAdOptions: NativeAdOptions(
        adChoicesPlacement: AdChoicesPlacement.topRightCorner,
        mediaAspectRatio: MediaAspectRatio.portrait,
        videoOptions: VideoOptions(
          clickToExpandRequested: true,
          customControlsRequested: true,
          startMuted: true,
        ),
        //shouldRequestMultipleImages: true,
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        // Required: Choose a template.
        templateType: TemplateType.small,
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
      // Styling
      // nativeTemplateStyle: NativeTemplateStyle(
      //   // Required: Choose a template.
      //   templateType: TemplateType.medium,
      //   // Optional: Customize the ad's style.
      //   mainBackgroundColor: Colors.transparent,
      //   cornerRadius: 25.0,
      //   callToActionTextStyle: NativeTemplateTextStyle(
      //     textColor: AppColors.white,
      //     backgroundColor: AppColors.color808BFF,
      //     style: NativeTemplateFontStyle.bold,
      //     size: 16,
      //   ),
      //   primaryTextStyle: NativeTemplateTextStyle(
      //     textColor: AppColors.blackColor,
      //     backgroundColor: AppColors.white,
      //     style: NativeTemplateFontStyle.normal,
      //     size: 18,
      //   ),
      //   secondaryTextStyle: NativeTemplateTextStyle(
      //     textColor: AppColors.blackColor,
      //     backgroundColor: AppColors.white,
      //     style: NativeTemplateFontStyle.normal,
      //     size: 16,
      //   ),
      //   tertiaryTextStyle: NativeTemplateTextStyle(
      //     textColor: AppColors.color808BFF,
      //     backgroundColor:AppColors.white,
      //     style: NativeTemplateFontStyle.normal,
      //     size: 15,
      //   ),
      // ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd=null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowAds || _adFailedToLoad) {
      return  SizedBox();
    } else if (_isAdLoaded && _nativeAd != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 320,
          minHeight: 100,
          maxWidth: 400,
          maxHeight: 120,
        ),
        child: AdWidget(ad: _nativeAd!),
      );
    } else {
      return const Center(
        child: Text(
          'Ad is loading',
        ),
      );
    }
  }
}
