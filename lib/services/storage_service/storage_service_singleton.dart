import 'package:web3modal_flutter/services/storage_service/i_storage_service.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service.dart';

class StorageServiceSingleton {
  IStorageService instance;

  StorageServiceSingleton() : instance = StorageService();
}

final storageService = StorageServiceSingleton();
