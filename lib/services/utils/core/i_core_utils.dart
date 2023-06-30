abstract class ICoreUtils {
  /// Returns true if the given [url] is a valid HTTP or HTTPS URL.
  bool isHttpUrl(String url);

  /// Formats a native URL for the given [appUrl] and [wcUri].
  Uri? formatNativeUrl(String? appUrl, String wcUri);

  /// Formats a universal URL for the given [appUrl] and [wcUri].
  Uri? formatUniversalUrl(String? appUrl, String wcUri);

  /// Returns the user agent string. Used with the explorer and other API endpoints.
  String getUserAgent();
}
