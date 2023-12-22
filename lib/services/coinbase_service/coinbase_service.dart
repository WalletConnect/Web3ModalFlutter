import 'dart:convert';

import 'package:coinbase_wallet_sdk/currency.dart';
import 'package:coinbase_wallet_sdk/return_value.dart';
import 'package:flutter/foundation.dart';

import 'package:event/event.dart';
import 'package:web3modal_flutter/services/coinbase_service/i_coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_events.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

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
  Event<CoinbaseSessionEvent> onCoinbaseSession = Event<CoinbaseSessionEvent>();

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
      throw W3MCoinbaseException(0, 'PairingMetadata error');
    }
  }

  @override
  Future<bool> cbIsInstalled() async {
    return await CoinbaseWalletSDK.shared.isAppInstalled();
  }

  @override
  Future<bool> cbIsConnected() async {
    return await CoinbaseWalletSDK.shared.isConnected();
  }

  @protected
  @override
  Future<void> cbGetAccount() async {
    try {
      final results = await CoinbaseWalletSDK.shared.initiateHandshake([
        const RequestAccounts(),
      ]);
      final data = CoinbaseData.fromJson(results.first.account!.toJson());
      onCoinbaseConnect.broadcast(CoinbaseConnectEvent(data));
    } catch (e, s) {
      W3MLoggerUtil.logger.e('[$runtimeType] getAccount(): $e, $s');
      onCoinbaseError.broadcast(CoinbaseErrorEvent(e.toString()));
    }
  }

  @override
  Future<void> cbRequest({
    String? chainId,
    required SessionRequestParams request,
  }) async {
    // _checkInitialized();
    try {
      final req = Request(actions: [request.toCoinbaseRequest(chainId)]);
      final results = await CoinbaseWalletSDK.shared.makeRequest(req);
      final errors = _checkError(results);
      if (errors != null) {
        onCoinbaseError.broadcast(CoinbaseErrorEvent(errors.message));
      } else {
        W3MLoggerUtil.logger
            .i('[$runtimeType] cbRequest: ${results.first.value}');
        switch (req.actions.first.method) {
          case 'wallet_switchEthereumChain':
          case 'wallet_addEthereumChain':
            onCoinbaseSession.broadcast(CoinbaseSessionEvent(chainId: chainId));
            break;
          case 'eth_requestAccounts':
            final json = jsonDecode(results.first.value!);
            final data = CoinbaseData.fromJson(json);
            onCoinbaseConnect.broadcast(CoinbaseConnectEvent(data));
            break;
          default:
            onCoinbaseSession.broadcast();
            break;
        }
      }
    } on W3MCoinbaseException {
      rethrow;
    } catch (e, s) {
      W3MLoggerUtil.logger.e('[$runtimeType] cbRequest: $e, $s');
      throw W3MCoinbaseException(0, e.toString());
    }
  }

  @override
  Future<void> cbResetSession() async {
    try {
      await CoinbaseWalletSDK.shared.resetSession();
      // onCoinbaseDisconnect.broadcast(CoinbaseDisconnectEvent());
    } catch (e) {
      throw W3MCoinbaseException(0, e.toString());
    }
  }

  ReturnValueError? _checkError(List<ReturnValue> results) {
    return results.first.error;
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
        } catch (_) {
          throw W3MCoinbaseException(0, 'Unrecognized chainId $chainId');
        }
      case 'wallet_watchAsset':
        return WatchAsset(params: params);
      default:
        throw W3MCoinbaseException(0, 'Unsupported request method $method');
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
