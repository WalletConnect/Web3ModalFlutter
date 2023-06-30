import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web3modal_flutter/services/utils/platform/i_platform_utils.dart';

class PlatformUtils extends IPlatformUtils {
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
  bool isMobileWidth(double width) {
    return width <= 500.0;
  }
}
