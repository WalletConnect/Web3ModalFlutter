import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';

class PlatformUtils extends IPlatformUtils {
  @override
  PlatformExact getPlatformExact() {
    if (Platform.isAndroid) {
      return PlatformExact.android;
    } else if (Platform.isIOS) {
      return PlatformExact.iOS;
    } else if (Platform.isLinux) {
      return PlatformExact.linux;
    } else if (Platform.isMacOS) {
      return PlatformExact.macOS;
    } else if (Platform.isWindows) {
      return PlatformExact.windows;
    } else if (kIsWeb) {
      return PlatformExact.web;
    }
    return PlatformExact.web;
  }

  @override
  PlatformType getPlatformType() {
    if (Platform.isAndroid || Platform.isIOS) {
      return PlatformType.mobile;
    } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return PlatformType.desktop;
    } else if (kIsWeb) {
      return PlatformType.web;
    }
    return PlatformType.mobile;
  }

  @override
  bool canDetectInstalledApps() {
    return getPlatformType() == PlatformType.mobile;
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
}
