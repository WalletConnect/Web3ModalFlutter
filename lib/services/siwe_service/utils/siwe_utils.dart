import 'package:walletconnect_flutter_v2/apis/sign_api/models/auth/common_auth_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/utils/auth/auth_signature.dart'
    as wcfv2;
import 'package:walletconnect_flutter_v2/apis/sign_api/utils/auth/auth_utils.dart';
import 'package:web3modal_flutter/services/siwe_service/models/w3m_siwe.dart';
import 'package:web3modal_flutter/services/siwe_service/siwe_service_singleton.dart';

class AuthSignature {
  /// Given SIWECreateMessageArgs will format message according to EIP-4361 https://docs.login.xyz/general-information/siwe-overview/eip-4361
  static String formatMessage(SIWECreateMessageArgs params) {
    return siweService.instance!.formatMessage(
      params,
    );
  }

  static String getAddressFromMessage(String message) {
    return wcfv2.AuthSignature.getAddressFromMessage(message);
  }

  static String getChainIdFromMessage(String message) {
    return wcfv2.AuthSignature.getChainIdFromMessage(message);
  }

  // verifies CACAO signature
  // Used by the wallet after formatting the message
  static Future<bool> verifySignature(
    String address,
    String message,
    CacaoSignature cacaoSignature,
    String chainId,
    String projectId,
  ) async {
    return wcfv2.AuthSignature.verifySignature(
      address,
      message,
      cacaoSignature,
      chainId,
      projectId,
    );
  }

  static String generateNonce() {
    return AuthUtils.generateNonce();
  }
}
