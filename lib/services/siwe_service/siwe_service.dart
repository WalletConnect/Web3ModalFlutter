import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:web3modal_flutter/services/coinbase_service/coinbase_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service_singleton.dart';
import 'package:web3modal_flutter/services/siwe_service/i_siwe_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class SiweService implements ISiweService {
  late final SIWEConfig? _siweConfig;
  final IWeb3App _web3app;

  SiweService({
    required IWeb3App web3app,
    required SIWEConfig? siweConfig,
  })  : _web3app = web3app,
        _siweConfig = siweConfig;

  @override
  SIWEConfig? get config => _siweConfig;

  @override
  bool get enabled => _siweConfig?.enabled == true;

  @override
  int get nonceRefetchIntervalMs =>
      _siweConfig?.nonceRefetchIntervalMs ?? 300000;

  @override
  int get sessionRefetchIntervalMs =>
      _siweConfig?.sessionRefetchIntervalMs ?? 300000;

  @override
  bool get signOutOnAccountChange =>
      _siweConfig?.signOutOnAccountChange ?? true;

  @override
  bool get signOutOnDisconnect => _siweConfig?.signOutOnDisconnect ?? true;

  @override
  bool get signOutOnNetworkChange =>
      _siweConfig?.signOutOnNetworkChange ?? true;

  @override
  Future<String> getNonce() async {
    if (!enabled) throw Exception('siweConfig not enabled');
    //
    return await _siweConfig!.getNonce();
  }

  @override
  Future<String> createMessage({
    required String chainId,
    required String address,
  }) async {
    if (!enabled) throw Exception('siweConfig not enabled');
    //
    final nonce = await getNonce();
    final messageParams = await _siweConfig!.getMessageParams();
    //
    final createMessageArgs = SIWECreateMessageArgs.fromSIWEMessageArgs(
      messageParams,
      address: '$chainId:$address',
      chainId: chainId,
      nonce: nonce,
      type: messageParams.type ?? CacaoHeader(t: 'eip4361'),
    );

    return _siweConfig!.createMessage(createMessageArgs);
  }

  @override
  Future<String> signMessageRequest(
    String message, {
    required W3MSession session,
  }) async {
    if (!enabled) throw Exception('siweConfig not enabled');
    //
    final chainId = AuthSignature.getChainIdFromMessage(message);
    final chain = W3MChainPresets.chains[chainId]!.namespace;
    final address = AuthSignature.getAddressFromMessage(message);
    final bytes = utf8.encode(message);
    final encoded = hex.encode(bytes);
    //
    if (session.sessionService.isMagic) {
      return await magicService.instance.request(
        chainId: chain,
        request: SessionRequestParams(
          method: 'personal_sign',
          params: ['0x$encoded', address],
        ),
      );
    }
    if (session.sessionService.isCoinbase) {
      return await coinbaseService.instance.request(
        chainId: chain,
        request: SessionRequestParams(
          method: 'personal_sign',
          params: ['0x$encoded', address],
        ),
      );
    }
    return await _web3app.request(
      topic: session.topic!,
      chainId: chain,
      request: SessionRequestParams(
        method: 'personal_sign',
        params: ['0x$encoded', address],
      ),
    );
  }

  @override
  Future<bool> verifyMessage({
    required String message,
    required String signature,
    Cacao? cacao,
    String? clientId,
  }) async {
    if (!enabled) throw Exception('siweConfig not enabled');
    //
    final verifyArgs = SIWEVerifyMessageArgs(
      message: message,
      signature: signature,
      cacao: cacao,
      clientId: clientId,
    );
    final isValid = await _siweConfig!.verifyMessage(verifyArgs);
    if (!isValid) {
      throw W3MServiceException('Error verifying SIWE signature');
    }
    return true;
  }

  @override
  Future<SIWESession> getSession() async {
    if (!enabled) throw Exception('siweConfig not enabled');
    //
    try {
      final siweSession = await _siweConfig!.getSession();
      if (siweSession == null) {
        throw W3MServiceException('Error getting SIWE session');
      }
      _siweConfig!.onSignIn?.call(siweSession);

      return siweSession;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    if (!enabled) throw Exception('siweConfig not enabled');

    final success = await _siweConfig!.signOut();
    if (!success) {
      throw W3MServiceException('signOut() from siweConfig failed');
    }
    _siweConfig!.onSignOut?.call();
  }

  @override
  String formatMessage(SIWECreateMessageArgs params) {
    final authPayload = SessionAuthPayload.fromJson({
      ...params.toJson(),
      'chains': [params.chainId],
      'aud': params.uri,
      'type': params.type?.t,
    });
    return _web3app.formatAuthMessage(
      iss: 'did:pkh:${params.address}',
      cacaoPayload: CacaoRequestPayload.fromSessionAuthPayload(authPayload),
    );
  }
}
