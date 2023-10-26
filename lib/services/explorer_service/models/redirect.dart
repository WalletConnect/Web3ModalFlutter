class WalletRedirect {
  String? mobile;
  String? desktop;
  String? web;

  WalletRedirect({
    this.mobile,
    this.desktop,
    this.web,
  });

  bool get mobileOnly => desktop == null && web == null;
  bool get webOnly => desktop == null && mobile == null;
  bool get desktopOnly => mobile == null && web == null;

  Uri? get mobileUri => mobile != null ? Uri.parse(mobile!) : null;
  Uri? get webUri => web != null ? Uri.parse(web!) : null;
  Uri? get desktopUri => desktop != null ? Uri.parse(desktop!) : null;

  @override
  String toString() => 'mobile: $mobile, desktop: $desktop, web: $web';
}
