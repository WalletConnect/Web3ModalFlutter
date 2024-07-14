import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_events.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class W3MCoinbaseException implements Exception {
  final String message;
  final dynamic error;
  final dynamic stackTrace;
  W3MCoinbaseException(
    this.message, [
    this.error,
    this.stackTrace,
  ]) : super();
}

class W3MCoinbaseNotInstalledException extends W3MCoinbaseException {
  W3MCoinbaseNotInstalledException() : super('App not installed');
}

class W3MCoinbaseNotEnabled extends W3MCoinbaseException {
  W3MCoinbaseNotEnabled() : super('Coinbase is disabled');
}

abstract class ICoinbaseService {
  Future<void> init();
  Future<bool> isConnected();
  Future<void> getAccount();
  Future<dynamic> request({
    required String chainId,
    required SessionRequestParams request,
  });
  Future<void> resetSession();
  Future<bool> isInstalled();

  Future<String> get ownPublicKey;
  Future<String> get peerPublicKey;

  ConnectionMetadata get metadata;

  abstract final Event<CoinbaseConnectEvent> onCoinbaseConnect;
  abstract final Event<CoinbaseErrorEvent> onCoinbaseError;
  abstract final Event<CoinbaseSessionEvent> onCoinbaseSessionUpdate;
  abstract final Event<CoinbaseResponseEvent> onCoinbaseResponse;
}
