import 'package:web3modal_flutter/services/storage_service/i_storage_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class StorageService implements IStorageService {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  String? getString(String key, {String? defaultValue}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  @override
  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  @override
  Future<void> clearAll() async {
    final keys = _prefs!.getKeys();
    for (var key in keys) {
      if (key.startsWith('w3m_')) {
        await _prefs!.remove(key);
      }
    }
  }

  @override
  Future<bool> clearKey(String key) async {
    return _prefs!.remove(key);
  }
}
