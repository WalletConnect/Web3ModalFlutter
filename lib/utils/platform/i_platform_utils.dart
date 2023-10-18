import 'package:flutter/material.dart';

enum PlatformType {
  mobile,
  desktop,
  web,
}

enum PlatformExact {
  iOS,
  android,
  web,
  macOS,
  windows,
  linux,
}

abstract class IPlatformUtils {
  PlatformExact getPlatformExact();

  PlatformType getPlatformType();

  bool canDetectInstalledApps();

  bool isBottomSheet();

  bool isLongBottomSheet(Orientation orientation);

  bool isMobileWidth(double width);
}
