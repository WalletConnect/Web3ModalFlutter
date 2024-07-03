import 'package:walletconnect_flutter_v2/apis/sign_api/models/auth/common_auth_models.dart';
import 'package:web3modal_flutter/services/siwe_service/models/w3m_siwe.dart';
import 'package:web3modal_flutter/services/w3m_service/models/w3m_session.dart';

abstract class ISiweService {
  SIWEConfig? get config;

  bool get enabled;
  bool get signOutOnDisconnect;
  bool get signOutOnAccountChange;
  bool get signOutOnNetworkChange;
  int get nonceRefetchIntervalMs;
  int get sessionRefetchIntervalMs;

  Future<String> getNonce();

  Future<String> createMessage({
    required String chainId,
    required String address,
  });

  Future<String> signMessageRequest(
    String message, {
    required W3MSession session,
  });

  Future<bool> verifyMessage({
    required String message,
    required String signature,
    Cacao? cacao,
    String? clientId,
  });

  Future<SIWESession> getSession();

  Future<void> signOut();

  String formatMessage(SIWECreateMessageArgs params);
}
