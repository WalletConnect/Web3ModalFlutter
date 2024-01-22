import 'package:web3modal_flutter/version.dart';
// ignore: implementation_imports
import 'package:walletconnect_flutter_v2/src/version.dart' as wcfv2;

class StringConstants {
  // Request Headers
  static const X_SDK_TYPE = 'w3m';
  static const X_SDK_VERSION = packageVersion;
  static const X_CORE_SDK_VERSION = 'flutter_${wcfv2.packageVersion}';

  // UI
  static const String selectNetwork = 'Select network';
  static const String selectNetworkShort = 'Network';
  static const String connected = 'Connected';
  static const String error = 'Error';
  static const String copyAddress = 'Copy Address';
  static const String disconnect = 'Disconnect';
  static const String addressCopied = 'Address copied';
  static const String noChain = 'No Chain';
  static const String connectButtonError = 'Network Error';
  static const String connectButtonReconnecting = 'Reconnecting';
  static const String connectButtonIdle = 'Connect wallet';
  static const String connectButtonIdleShort = 'Connect';
  static const String connectButtonConnecting = 'Connecting...';
  static const String connectButtonConnected = 'Disconnect';

  // Misc
  static const String noResults = 'No results found';
  static const String namespace = 'eip155';

  // Storage
  static const String recentWalletId = 'w3m_recentWallet';
  static const String connectedWalletData = 'w3m_walletData';
  static const String selectedChainId = 'w3m_selectedChainId';
  static const String w3mSession = 'w3m_session';

  // Urls
  static const String exploreAllWallets =
      'https://explorer.walletconnect.com/?type=wallet';
  static const String learnMoreUrl =
      'https://ethereum.org/en/developers/docs/networks/';
}
