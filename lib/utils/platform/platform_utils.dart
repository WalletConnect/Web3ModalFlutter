import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';

class PlatformUtils extends IPlatformUtils {
  bool get _runsOnIos =>
      (kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ||
      (!kIsWeb && Platform.isIOS);
  bool get _runsOnAndroid =>
      (kIsWeb && defaultTargetPlatform == TargetPlatform.android) ||
      (!kIsWeb && Platform.isAndroid);

  @override
  PlatformExact getPlatformExact() {
    if (_runsOnAndroid) {
      return PlatformExact.android;
    } else if (_runsOnIos) {
      return PlatformExact.iOS;
    } else if (kIsWeb) {
      return PlatformExact.web;
    } else if (Platform.isLinux) {
      return PlatformExact.linux;
    } else if (Platform.isMacOS) {
      return PlatformExact.macOS;
    } else if (Platform.isWindows) {
      return PlatformExact.windows;
    }
    return PlatformExact.web;
  }

  @override
  PlatformType getPlatformType() {
    if (_runsOnAndroid || _runsOnIos) {
      return PlatformType.mobile;
    } else if (!kIsWeb &&
        (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      return PlatformType.desktop;
    } else if (kIsWeb) {
      return PlatformType.web;
    }
    return PlatformType.mobile;
  }

  @override
  bool canDetectInstalledApps() {
    return !kIsWeb && getPlatformType() == PlatformType.mobile;
  }

  @override
  bool isBottomSheet() {
    return getPlatformType() == PlatformType.mobile;
  }

  @override
  bool isLongBottomSheet(Orientation orientation) {
    return getPlatformType() == PlatformType.mobile &&
        orientation == Orientation.landscape;
  }

  @override
  bool isMobileWidth(double width) {
    return width <= 500.0;
  }

  @override
  bool isTablet(BuildContext context) {
    final mqData = MediaQueryData.fromView(View.of(context));
    return mqData.size.shortestSide < 600 ? false : true;
  }
}
