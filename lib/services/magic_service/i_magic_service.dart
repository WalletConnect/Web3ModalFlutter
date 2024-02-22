import 'package:web3modal_flutter/services/magic_service/models/magic_events.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

enum EmailLoginStep {
  verifyDevice('VERIFY_DEVICE'),
  verifyOtp('VERIFY_OTP'),
  loading('LOADING'),
  idle('');

  final String action;
  const EmailLoginStep(this.action);

  factory EmailLoginStep.fromAction(String action) {
    return values.firstWhere((e) => e.action == action);
  }
}

abstract class IMagicService {
  Future<void> init();
  Future<void> loadRequest();
  void setEmail(String value);

  // ****** W3mFrameProvider public methods ******* //
  Future<void> connectEmail({required String value});
  Future<void> connectDevice();
  Future<void> connectOtp({required String otp});
  Future<void> isConnected();
  Future<void> getChainId();
  // Future<void> updateEmail({required String email});
  Future<void> syncTheme(Web3ModalTheme? theme);
  Future<void> syncDappData();
  Future<void> getUser({String? chainId});
  Future<void> switchNetwork({required String chainId});
  Future<void> request({required Map<String, dynamic> parameters});
  Future<void> disconnect();

  abstract final Event<MagicSessionEvent> onMagicLoginRequest;
  abstract final Event<MagicConnectEvent> onMagicLoginSuccess;
  abstract final Event<MagicSessionEvent> onMagicUpdate;
  abstract final Event<MagicErrorEvent> onMagicError;
  abstract final Event<MagicRequestEvent> onMagicRpcRequest;
}
