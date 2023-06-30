abstract class IUrlUtils {
  const IUrlUtils();

  Future<bool> isInstalled(String? uri);

  Future<void> launchRedirect({
    Uri? nativeUri,
    Uri? universalUri,
  });

  Future<void> navigateDeepLink({
    String? nativeLink,
    String? universalLink,
    required String wcURI,
  });
}
