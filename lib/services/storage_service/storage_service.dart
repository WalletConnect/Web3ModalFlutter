import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3modal_flutter/services/storage_service/i_storage_service.dart';

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
    return _prefs!.setString(key, value);
  }
}
