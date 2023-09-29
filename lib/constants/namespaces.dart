import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

// TODO this is not used on package side, check if it's needed.
class NamespaceConstants {
  static const Map<String, RequiredNamespace> ethereum = {
    'eip155': RequiredNamespace(
      methods: [
        'eth_sendTransaction',
        // 'eth_signTransaction',
        'personal_sign',
        'eth_sign',
        'eth_signTypedData',
      ],
      chains: ['eip155:1'],
      events: [
        'chainChanged',
        'accountsChanged',
      ],
    ),
  };

  static const Map<String, RequiredNamespace> polygon = {
    'eip155': RequiredNamespace(
      methods: [
        'eth_sendTransaction',
        'eth_signTransaction',
        'personal_sign',
        // 'eth_sign',
        'eth_signTypedData',
      ],
      chains: ['eip155:137'],
      events: [
        'chainChanged',
        'accountsChanged',
      ],
    ),
  };
}
