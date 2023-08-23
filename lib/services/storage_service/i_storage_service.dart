abstract class IStorageService {
  Future<void> init();
  String? getString(String key);
  Future<bool> setString(String key, String value);
}
