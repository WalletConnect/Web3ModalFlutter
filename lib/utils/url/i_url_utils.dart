import 'package:url_launcher/url_launcher.dart';

abstract class IUrlUtils {
  const IUrlUtils();

  Future<bool> isInstalled(String? uri);

  Future<bool> launchUrl(
    Uri url, {
    LaunchMode? mode,
  });

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
