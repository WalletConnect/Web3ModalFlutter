enum PlatformType {
  mobile,
  desktop,
  web,
}

abstract class IPlatformUtils {
  PlatformType getPlatformType();

  bool isMobileWidth(double width);
}
