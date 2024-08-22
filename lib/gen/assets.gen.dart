/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/images/appbg.png
  AssetGenImage get appbg =>
      const AssetGenImage('assets/images/appbg.png');

  /// File path: assets/images/images/equipment.png
  AssetGenImage get equipment =>
      const AssetGenImage('assets/images/equipment.png');

  /// File path: assets/images/images/fertilizers.png
  AssetGenImage get fertilizers =>
      const AssetGenImage('assets/images/fertilizers.png');

  /// File path: assets/images/images/fertilizers_1.png
  AssetGenImage get fertilizers1 =>
      const AssetGenImage('assets/images/fertilizers_1.png');

  /// File path: assets/images/images/ffb_collection.png
  AssetGenImage get ffbCollection =>
      const AssetGenImage('assets/images/ffb_collection.png');

  /// File path: assets/images/images/general.png
  AssetGenImage get general =>
      const AssetGenImage('assets/images/general.png');

  /// File path: assets/images/images/harvesting.png
  AssetGenImage get harvesting =>
      const AssetGenImage('assets/images/harvesting.png');

  /// File path: assets/images/images/ic_bank_white.png
  AssetGenImage get icBankWhite =>
      const AssetGenImage('assets/images/ic_bank_white.png');

  /// File path: assets/images/images/ic_calender.png
  AssetGenImage get icCalender =>
      const AssetGenImage('assets/images/ic_calender.png');

  /// File path: assets/images/images/ic_care.svg
  SvgGenImage get icCare =>
      const SvgGenImage('assets/images/ic_care.svg');

  /// File path: assets/images/images/ic_home.svg
  SvgGenImage get icHome =>
      const SvgGenImage('assets/images/ic_home.svg');

  /// File path: assets/images/images/ic_left.png
  AssetGenImage get icLeft =>
      const AssetGenImage('assets/images/ic_left.png');

  /// File path: assets/images/images/ic_lernin.png
  AssetGenImage get icLernin =>
      const AssetGenImage('assets/images/ic_lernin.png');

  /// File path: assets/images/images/ic_logo.png
  AssetGenImage get icLogo =>
      const AssetGenImage('assets/images/ic_logo.png');

  /// File path: assets/images/images/ic_my.svg
  SvgGenImage get icMy => const SvgGenImage('assets/images/ic_my.svg');

  /// File path: assets/images/images/ic_myprofile.svg
  SvgGenImage get icMyprofile =>
      const SvgGenImage('assets/images/ic_myprofile.svg');

  /// File path: assets/images/images/ic_request.svg
  SvgGenImage get icRequest =>
      const SvgGenImage('assets/images/ic_request.svg');

  /// File path: assets/images/images/ic_user.png
  AssetGenImage get icUser =>
      const AssetGenImage('assets/images/ic_user.png');

  /// File path: assets/images/images/labour.png
  AssetGenImage get labour =>
      const AssetGenImage('assets/images/labour.png');

  /// File path: assets/images/images/loan.png
  AssetGenImage get loan =>
      const AssetGenImage('assets/images/loan.png');

  /// File path: assets/images/images/main_visit.png
  AssetGenImage get mainVisit =>
      const AssetGenImage('assets/images/main_visit.png');

  /// File path: assets/images/images/oilpalm.png
  AssetGenImage get oilpalm =>
      const AssetGenImage('assets/images/oilpalm.png');

  /// File path: assets/images/images/passbook.png
  AssetGenImage get passbook =>
      const AssetGenImage('assets/images/passbook.png');

  /// File path: assets/images/images/pest.png
  AssetGenImage get pest =>
      const AssetGenImage('assets/images/pest.png');

  /// File path: assets/images/images/quick_pay.png
  AssetGenImage get quickPay =>
      const AssetGenImage('assets/images/quick_pay.png');

  /// File path: assets/images/images/visit.png
  AssetGenImage get visit =>
      const AssetGenImage('assets/images/visit.png');

  /// List of all assets
  List<dynamic> get values => [
        appbg,
        equipment,
        fertilizers,
        fertilizers1,
        ffbCollection,
        general,
        harvesting,
        icBankWhite,
        icCalender,
        icCare,
        icHome,
        icLeft,
        icLernin,
        icLogo,
        icMy,
        icMyprofile,
        icRequest,
        icUser,
        labour,
        loan,
        mainVisit,
        oilpalm,
        passbook,
        pest,
        quickPay,
        visit
      ];
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

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

class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = false;

  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final BytesLoader loader;
    if (_isVecFormat) {
      loader = AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
