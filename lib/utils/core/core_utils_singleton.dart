import 'package:web3modal_flutter/utils/core/core_utils.dart';
import 'package:web3modal_flutter/utils/core/i_core_utils.dart';

class CoreUtilsSingleton {
  ICoreUtils instance;

  CoreUtilsSingleton() : instance = CoreUtils();
}

final coreUtils = CoreUtilsSingleton();
