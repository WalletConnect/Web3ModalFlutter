import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/apis/core/relay_client/relay_client.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service.dart';
import 'package:web3modal_flutter/services/ledger_service/ledger_service.dart';
import 'package:web3modal_flutter/services/network_service/network_service.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service.dart';
import 'package:web3modal_flutter/utils/platform/platform_utils.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils.dart';
import 'package:web3modal_flutter/utils/url/url_utils.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack.dart';

import 'mock_classes.mocks.dart';

@GenerateMocks([
  ExplorerService,
  W3MService,
  UrlUtils,
  PlatformUtils,
  ToastUtils,
  Web3App,
  Sessions,
  RelayClient,
  http.Client,
  NetworkService,
  BlockchainApiUtils,
  LedgerService,
  StorageService,
  WidgetStack,
])
class Mocks {}

class W3MServiceSpy extends MockW3MService {
  final List<VoidCallback> _listeners = [];

  @override
  void addListener(VoidCallback? listener) {
    if (listener != null) {
      _listeners.add(listener);
    }
  }

  @override
  void removeListener(VoidCallback? listener) {
    _listeners.remove(listener);
  }

  @override
  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}
