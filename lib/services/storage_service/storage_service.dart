import 'package:web3modal_flutter/constants/string_constants.dart';
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
  Future<bool> clearAll() async {
    final walletData = getString(StringConstants.walletData, defaultValue: '');
    final result = await _prefs!.clear();
    if (walletData!.isNotEmpty) {
      await setString(StringConstants.walletData, walletData);
    }
    return result;
  }

  @override
  Future<bool> clearKey(String key) async {
    return _prefs!.remove(key);
  }
}
