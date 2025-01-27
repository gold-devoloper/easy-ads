import 'package:easy_ads_flutter/src/easy_ad_base.dart';
import 'package:easy_ads_flutter/src/enums/ad_network.dart';
import 'package:easy_ads_flutter/src/enums/ad_unit_type.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class EasyAdManagerInterstitialAd extends EasyAdBase {
  final AdManagerAdRequest _adRequest;
  final bool _immersiveModeEnabled;

  EasyAdManagerInterstitialAd(
    String adUnitId,
    this._adRequest,
    this._immersiveModeEnabled,
  ) : super(adUnitId);

  AdManagerInterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  AdNetwork get adNetwork => AdNetwork.adManager;

  @override
  AdUnitType get adUnitType => AdUnitType.interstitial;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  void dispose() {
    _isAdLoaded = false;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded) return;

    await AdManagerInterstitialAd.load(
        adUnitId: adUnitId,
        request: _adRequest,
        adLoadCallback: AdManagerInterstitialAdLoadCallback(
          onAdLoaded: (AdManagerInterstitialAd ad) {
            _interstitialAd = ad;
            _isAdLoaded = true;
            onAdLoaded?.call(adNetwork, adUnitType, ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            _isAdLoaded = false;
            onAdFailedToLoad?.call(adNetwork, adUnitType, error, error.toString());
          },
        ));
  }

  @override
  show() {
    final ad = _interstitialAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AdManagerInterstitialAd ad) {
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (AdManagerInterstitialAd ad) {
        onAdDismissed?.call(adNetwork, adUnitType, ad);

        ad.dispose();
        load();
      },
      onAdFailedToShowFullScreenContent: (AdManagerInterstitialAd ad, AdError error) {
        onAdFailedToShow?.call(adNetwork, adUnitType, ad, error.toString());

        ad.dispose();
        load();
      },
    );
    ad.setImmersiveMode(_immersiveModeEnabled);
    ad.show();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}
