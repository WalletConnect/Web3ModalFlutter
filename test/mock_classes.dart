import 'package:web3modal_flutter/services/utils/platform/platform_utils.dart';
import 'package:web3modal_flutter/services/utils/url/url_utils.dart';
import 'package:web3modal_flutter/walletconnect_modal_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([
  ExplorerService,
  WalletConnectModalService,
  UrlUtils,
  PlatformUtils,
  http.Client,
])
class Mocks {}
