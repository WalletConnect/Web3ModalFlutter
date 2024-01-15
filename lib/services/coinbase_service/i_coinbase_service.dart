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

abstract class ICoinbaseService {
  Future<void> cbInit({required PairingMetadata metadata});
  Future<bool> cbIsConnected();
  Future<void> cbGetAccount();
  Future<dynamic> cbRequest({
    required String chainId,
    required SessionRequestParams request,
  });
  Future<void> cbResetSession();
  Future<bool> cbIsInstalled();

  abstract final Event<CoinbaseConnectEvent> onCoinbaseConnect;
  abstract final Event<CoinbaseErrorEvent> onCoinbaseError;
  abstract final Event<CoinbaseSessionEvent> onCoinbaseSessionUpdate;
  abstract final Event<CoinbaseResponseEvent> onCoinbaseResponse;
}
