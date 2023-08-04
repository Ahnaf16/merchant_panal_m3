/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class Assets {
  Assets._();

  /// File path: assets/bank/bkash.png
  static const AssetGenImage bankBkash = AssetGenImage('assets/bank/bkash.png');

  /// File path: assets/bank/nagad.png
  static const AssetGenImage bankNagad = AssetGenImage('assets/bank/nagad.png');

  /// File path: assets/bank/ssl.png
  static const AssetGenImage bankSsl = AssetGenImage('assets/bank/ssl.png');

  /// File path: assets/logo/logo.png
  static const AssetGenImage logoLogo = AssetGenImage('assets/logo/logo.png');

  /// File path: assets/logo/logo_alpha.png
  static const AssetGenImage logoLogoAlpha =
      AssetGenImage('assets/logo/logo_alpha.png');

  /// File path: assets/logo/logo_dark.png
  static const AssetGenImage logoLogoDark =
      AssetGenImage('assets/logo/logo_dark.png');

  /// File path: assets/logo/logo_dark_splash.png
  static const AssetGenImage logoLogoDarkSplash =
      AssetGenImage('assets/logo/logo_dark_splash.png');

  /// File path: assets/logo/logo_full_dark.png
  static const AssetGenImage logoLogoFullDark =
      AssetGenImage('assets/logo/logo_full_dark.png');

  /// File path: assets/lottie/loading.json
  static const LottieGenImage lottieLoading =
      LottieGenImage('assets/lottie/loading.json');

  /// File path: assets/misc/gcoin.png
  static const AssetGenImage miscGcoin = AssetGenImage('assets/misc/gcoin.png');

  /// File path: assets/misc/go_protect.png
  static const AssetGenImage miscGoProtect =
      AssetGenImage('assets/misc/go_protect.png');

  /// File path: assets/misc/stamp_condition.png
  static const AssetGenImage miscStampCondition =
      AssetGenImage('assets/misc/stamp_condition.png');

  /// File path: assets/misc/stamp_full_paid.png
  static const AssetGenImage miscStampFullPaid =
      AssetGenImage('assets/misc/stamp_full_paid.png');

  /// List of all assets
  List<dynamic> get values => [
        bankBkash,
        bankNagad,
        bankSsl,
        logoLogo,
        logoLogoAlpha,
        logoLogoDark,
        logoLogoDarkSplash,
        logoLogoFullDark,
        lottieLoading,
        miscGcoin,
        miscGoProtect,
        miscStampCondition,
        miscStampFullPaid
      ];
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class LottieGenImage {
  const LottieGenImage(this._assetName);

  final String _assetName;

  LottieBuilder lottie({
    Animation<double>? controller,
    bool? animate,
    FrameRate? frameRate,
    bool? repeat,
    bool? reverse,
    LottieDelegates? delegates,
    LottieOptions? options,
    void Function(LottieComposition)? onLoaded,
    LottieImageProviderFactory? imageProviderFactory,
    Key? key,
    AssetBundle? bundle,
    Widget Function(BuildContext, Widget, LottieComposition?)? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    String? package,
    bool? addRepaintBoundary,
    FilterQuality? filterQuality,
    void Function(String)? onWarning,
  }) {
    return Lottie.asset(
      _assetName,
      controller: controller,
      animate: animate,
      frameRate: frameRate,
      repeat: repeat,
      reverse: reverse,
      delegates: delegates,
      options: options,
      onLoaded: onLoaded,
      imageProviderFactory: imageProviderFactory,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      package: package,
      addRepaintBoundary: addRepaintBoundary,
      filterQuality: filterQuality,
      onWarning: onWarning,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
