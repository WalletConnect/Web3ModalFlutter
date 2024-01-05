import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:web3modal_flutter/services/coinbase_service/i_coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_events.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:coinbase_wallet_sdk/currency.dart';
import 'package:coinbase_wallet_sdk/action.dart';
import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk.dart';
import 'package:coinbase_wallet_sdk/configuration.dart';
import 'package:coinbase_wallet_sdk/eth_web3_rpc.dart';
import 'package:coinbase_wallet_sdk/request.dart';

import 'models/coinbase_data.dart';

class CoinbaseService implements ICoinbaseService {
  @override
  Event<CoinbaseConnectEvent> onCoinbaseConnect = Event<CoinbaseConnectEvent>();

  @override
  Event<CoinbaseErrorEvent> onCoinbaseError = Event<CoinbaseErrorEvent>();

  @override
  Event<CoinbaseSessionEvent> onCoinbaseSessionUpdate =
      Event<CoinbaseSessionEvent>();

  @override
  Event<CoinbaseResponseEvent> get onCoinbaseResponse =>
      Event<CoinbaseResponseEvent>();

  @protected
  @override
  Future<void> cbInit({required PairingMetadata metadata}) async {
    // Configure SDK for each platform
    final universal = metadata.redirect?.universal ?? metadata.url;
    final nativeLink = metadata.redirect?.native ?? '';
    if (universal.isNotEmpty && nativeLink.isNotEmpty) {
      try {
        final config = Configuration(
          ios: IOSConfiguration(
            host: Uri.parse('cbwallet://wsegue'),
            callback: Uri.parse(nativeLink),
          ),
          android: AndroidConfiguration(domain: Uri.parse(universal)),
        );
        await CoinbaseWalletSDK.shared.configure(config);
      } catch (_) {
        // Silent error
      }
    } else {
      throw W3MCoinbaseException('PairingMetadata error');
    }
  }

  @protected
  @override
  Future<void> cbGetAccount() async {
    try {
      final result = (await CoinbaseWalletSDK.shared.initiateHandshake([
        const RequestAccounts(),
      ]))
          .first;
      if (result.error != null) {
        final errorCode = result.error?.code;
        final errorMessage = result.error!.message;
        onCoinbaseError.broadcast(CoinbaseErrorEvent(errorMessage));
        throw CoinbaseRPCError(errorCode, errorMessage);
      }
      final data = CoinbaseData.fromJson(result.account!.toJson());
      onCoinbaseConnect.broadcast(CoinbaseConnectEvent(data));
    } on PlatformException catch (e, s) {
      final message = (e.message ?? '').toLowerCase();
      final error0 = message.contains('error 0');
      final denied = message.contains('user denied');
      if (error0 || denied) {
        throw CoinbaseRPCError(0, 'User denied handshake');
      }
      throw W3MCoinbaseException(e, s);
    } catch (e, s) {
      onCoinbaseError.broadcast(CoinbaseErrorEvent(e.toString()));
      throw W3MCoinbaseException(e, s);
    }
  }

  @override
  Future<dynamic> cbRequest({
    String? chainId,
    required SessionRequestParams request,
  }) async {
    try {
      final req = Request(actions: [request.toCoinbaseRequest(chainId)]);
      final result = (await CoinbaseWalletSDK.shared.makeRequest(req)).first;
      if (result.error != null) {
        final errorCode = result.error?.code;
        final errorMessage = result.error!.message;
        onCoinbaseError.broadcast(CoinbaseErrorEvent(errorMessage));
        throw CoinbaseRPCError(errorCode, errorMessage);
      }
      switch (req.actions.first.method) {
        case 'wallet_switchEthereumChain':
        case 'wallet_addEthereumChain':
          final event = CoinbaseSessionEvent(chainId: chainId);
          onCoinbaseSessionUpdate.broadcast(event);
          break;
        case 'eth_requestAccounts':
          final json = jsonDecode(result.value!);
          final data = CoinbaseData.fromJson(json);
          onCoinbaseConnect.broadcast(CoinbaseConnectEvent(data));
          break;
        default:
          final data = result.value;
          onCoinbaseResponse.broadcast(CoinbaseResponseEvent(data: data));
          break;
      }
      return result.value;
    } on W3MCoinbaseException {
      rethrow;
    } catch (e, s) {
      throw W3MCoinbaseException(e, s);
    }
  }

  @override
  Future<bool> cbIsInstalled() async {
    try {
      return await CoinbaseWalletSDK.shared.isAppInstalled();
    } catch (e, s) {
      throw W3MCoinbaseException(e, s);
    }
  }

  @override
  Future<bool> cbIsConnected() async {
    try {
      return await CoinbaseWalletSDK.shared.isConnected();
    } catch (e, s) {
      throw W3MCoinbaseException(e, s);
    }
  }

  @override
  Future<void> cbResetSession() async {
    try {
      return CoinbaseWalletSDK.shared.resetSession();
    } catch (e, s) {
      throw W3MCoinbaseException(e, s);
    }
  }
}

extension on SessionRequestParams {
  Action toCoinbaseRequest(String? chainId) {
    switch (method) {
      case 'personal_sign':
        final address = _getAddressFromParamsList(params);
        final message = _getDataFromParamsList(params);
        return PersonalSign(address: address, message: message);
      case 'eth_signTypedData_v3':
        final address = _getAddressFromParamsList(params);
        final jsonData = _getDataFromParamsList(params);
        return SignTypedDataV3(address: address, typedDataJson: jsonData);
      case 'eth_signTypedData_v4':
        final address = _getAddressFromParamsList(params);
        final jsonData = _getDataFromParamsList(params);
        return SignTypedDataV4(address: address, typedDataJson: jsonData);
      case 'eth_requestAccounts':
        return RequestAccounts();
      case 'eth_signTransaction':
        final jsonData = _getTransactionFromParams(params);
        final hexValue = jsonData['value'].toString().replaceFirst('0x', '');
        final value = int.parse(hexValue, radix: 16);
        return SignTransaction(
          fromAddress: jsonData['from'],
          toAddress: jsonData['to'],
          chainId: chainId!,
          weiValue: BigInt.from(value),
          data: jsonData['data'],
        );
      case 'eth_sendTransaction':
        final jsonData = _getTransactionFromParams(params);
        return SendTransaction(
          fromAddress: jsonData['from'],
          toAddress: jsonData['to'],
          chainId: chainId!,
          weiValue: jsonData['value'],
          data: jsonData['data'],
        );
      case 'wallet_switchEthereumChain':
      case 'wallet_addEthereumChain':
        try {
          final chainInfo = W3MChainPresets.chains[chainId!]!;
          final iconUrls =
              chainInfo.chainIcon != null ? [chainInfo.chainIcon!] : null;
          final explorerUrls = chainInfo.blockExplorer != null
              ? [chainInfo.blockExplorer!.url]
              : null;
          return AddEthereumChain(
            chainId: chainInfo.chainId,
            rpcUrls: [chainInfo.rpcUrl],
            chainName: chainInfo.chainName,
            nativeCurrency: Currency(
              name: chainInfo.tokenName,
              symbol: chainInfo.tokenName,
              decimals: 18,
            ),
            iconUrls: iconUrls,
            blockExplorerUrls: explorerUrls,
          );
        } catch (_, s) {
          throw W3MCoinbaseException('Unrecognized chainId $chainId', s);
        }
      case 'wallet_watchAsset':
        return WatchAsset(params: params);
      default:
        throw W3MCoinbaseException('Unsupported request method $method');
    }
  }

  String _getAddressFromParamsList(dynamic params) {
    return (params as List).firstWhere((p) {
      try {
        EthereumAddress.fromHex(p);
        return true;
      } catch (e) {
        return false;
      }
    });
  }

  dynamic _getDataFromParamsList(dynamic params) {
    return (params as List).firstWhere((p) {
      final address = _getAddressFromParamsList(params);
      return p != address;
    });
  }

  Map<String, dynamic> _getTransactionFromParams(dynamic params) {
    final param = (params as List<dynamic>).first;
    return param as Map<String, dynamic>;
  }
}

class WatchAsset extends Action {
  WatchAsset({required dynamic params})
      : super(
          method: 'wallet_watchAsset',
          paramsJson: jsonEncode(params),
        );
}
