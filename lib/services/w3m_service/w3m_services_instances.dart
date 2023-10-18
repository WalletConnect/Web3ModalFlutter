import 'package:web3modal_flutter/services/storage_service/i_storage_service.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/utils/core/i_core_utils.dart';
import 'package:web3modal_flutter/widgets/widget_stack/i_widget_stack.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';

import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/utils/platform/platform_utils_singleton.dart';
import 'package:web3modal_flutter/utils/toast/i_toast_utils.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils_singleton.dart';
import 'package:web3modal_flutter/utils/url/i_url_utils.dart';
import 'package:web3modal_flutter/utils/url/url_utils_singleton.dart';

// TODO this is not really needed
class Web3ModalServiceInstances {
  static IStorageService get storage => storageService.instance;
  static ICoreUtils get core => coreUtils.instance;
  static IToastUtils get toast => toastUtils.instance;
  static IUrlUtils get url => urlUtils.instance;
  static IWidgetStack get stack => widgetStack.instance;
  static IPlatformUtils get platform => platformUtils.instance;

  static final Map<String, Function> _initFunctions = {};

  /// Register a function to be called during [init], which is called when a WalletConnectModalService
  /// or any inherited version of it is created.
  static void registerInitFunction(String name, Function function) {
    _initFunctions[name] = function;
  }

  // static final Map<Type, Future> initFunctionsMap = {};

  static Future<void> init() async {
    await storage.init();
    for (final entry in _initFunctions.entries) {
      await entry.value();
    }
  }
}
