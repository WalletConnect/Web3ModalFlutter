import 'dart:convert';

import 'package:coinbase_wallet_sdk/account.dart';
import 'package:coinbase_wallet_sdk/action.dart';
import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk.dart';
import 'package:coinbase_wallet_sdk/configuration.dart';
import 'package:coinbase_wallet_sdk/eth_web3_rpc.dart';
import 'package:coinbase_wallet_sdk/request.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3modal_flutter/utils/w3m_logger.dart';
// import 'package:coinbase_wallet_sdk/request.dart';

import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:flutter/foundation.dart';

// final coinbaseService = CoinbaseServiceSingleton();

// class CoinbaseServiceSingleton {
//   late ICoinbaseService instance;
// }

class W3MCoinbaseException implements Exception {
  final int code;
  final String message;
  final dynamic stackTrace;
  W3MCoinbaseException(this.code, this.message, [this.stackTrace]) : super();
}

abstract class ICoinbaseService {
  Future<void> cbInit({required PairingMetadata metadata});
  Future<bool> cbIsConnected();
  Future<Account?> cbGetAccount();
  Future<dynamic> cbRequest({
    String? topic,
    required String chainId,
    required SessionRequestParams request,
  });
  Future<void> cbResetSession();
  Future<bool> cbCheckInstalled();
}

class CoinbaseService implements ICoinbaseService {
  // late final PairingMetadata _metadata;
  // CoinbaseService({required PairingMetadata metadata}) : _metadata = metadata;
  bool _initialized = false;

  @protected
  @override
  Future<void> cbInit({required PairingMetadata metadata}) async {
    // Reset previous session
    // await CoinbaseWalletSDK.shared.resetSession();
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
          android: AndroidConfiguration(
            domain: Uri.parse(universal),
          ),
        );
        await CoinbaseWalletSDK.shared.configure(config);
        _initialized = true;
      } catch (e) {
        debugPrint('initCoinbase: $e');
      }
    } else {
      throw ArgumentError(
          'metada.redirect must be set to properly integrate Coinbase Wallet');
    }
  }

  void _checkInitialized() {
    if (!_initialized) {
      throw W3MCoinbaseException(-1, 'Coinbase is not initialized');
    }
  }

  @override
  Future<bool> cbIsConnected() async {
    _checkInitialized();
    return await CoinbaseWalletSDK.shared.isConnected();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  @protected
  @override
  Future<Account?> cbGetAccount() async {
    _checkInitialized();
    try {
      final results = await CoinbaseWalletSDK.shared.initiateHandshake([
        const RequestAccounts(),
      ]);
      return results[0].account;
    } catch (e, s) {
      W3MLoggerUtil.logger.e('[$runtimeType] getAccount(): $e, $s');
      return null;
    }
  }

  @override
  Future<dynamic> cbRequest({
    String? topic,
    String? chainId,
    required SessionRequestParams request,
  }) async {
    _checkInitialized();
    debugPrint(
        '[CoinbaseService] cbRequest: $topic, $chainId, ${request.toJson()}');
    final req = Request(actions: [request.toCoinbaseRequest(chainId)]);
    final results = await CoinbaseWalletSDK.shared.makeRequest(req);
    if (results[0].error != null) {
      final message = results[0].error!.message;
      final code = results[0].error!.code;
      throw W3MCoinbaseException(code, message);
    }
    return results[0].value;
  }

  @override
  Future<void> cbResetSession() async {
    _checkInitialized();
    try {
      return CoinbaseWalletSDK.shared.resetSession();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Future<bool> cbCheckInstalled() async {
    _checkInitialized();
    return await CoinbaseWalletSDK.shared.isAppInstalled();
  }

  static const List<String> approvedMethods = [
    'eth_requestAccounts',
    'eth_signTransaction',
    'eth_sendTransaction',
    'personal_sign',
    'eth_signTypedData_v3',
    'eth_signTypedData_v4',
    'wallet_switchEthereumChain',
    'wallet_addEthereumChain',
    'wallet_watchAsset',
  ];
}

extension on SessionRequestParams {
  Action toCoinbaseRequest(String? chainId) {
    debugPrint('SessionRequestParams ${toJson()}');
    switch (method) {
      case 'personal_sign':
        final address = _getAddressFromParams(params);
        final message = _getDataFromParams(params);
        return PersonalSign(
          address: address,
          message: message,
        );
      case 'eth_signTypedData_v3':
        final address = _getAddressFromParams(params);
        final jsonData = _getDataFromParams(params);
        return SignTypedDataV3(
          address: address,
          typedDataJson: jsonData,
        );
      case 'eth_signTypedData_v4':
        final address = _getAddressFromParams(params);
        final jsonData = _getDataFromParams(params);
        return SignTypedDataV4(
          address: address,
          typedDataJson: jsonData,
        );
      case 'wallet_switchEthereumChain':
      case 'wallet_addEthereumChain':
        try {
          final chainInfo = W3MChainPresets.chains[chainId!]!;
          return AddEthereumChain(
            chainInfo: chainInfo,
          );
        } catch (_) {
          throw Exception('Unrecognized chainId $chainId');
        }
      case 'eth_requestAccounts':
        throw Exception('Unsupported request method $method');
      case 'eth_signTransaction':
        throw Exception('Unsupported request method $method');
      case 'eth_sendTransaction':
        final jsonData = _getDataFromParams(params);

        debugPrint('jsonData $jsonData');
        throw Exception('Unsupported request method $method');
      // return SendTransaction(
      //   fromAddress: '',
      //   toAddress: '',
      //   weiValue: null,
      //   data: '',
      //   chainId: '',
      // );
      case 'wallet_watchAsset':
        throw Exception('Unsupported request method $method');
      default:
        throw Exception('Unsupported request method $method');
    }
  }

  String _getAddressFromParams(dynamic params) {
    return (params as List).firstWhere((p) {
      try {
        EthereumAddress.fromHex(p);
        return true;
      } catch (e) {
        return false;
      }
    });
  }

  dynamic _getDataFromParams(dynamic params) {
    return (params as List).firstWhere((p) {
      final address = _getAddressFromParams(params);
      return p != address;
    });
  }
}

class AddEthereumChain extends Action {
  AddEthereumChain({required W3MChainInfo chainInfo})
      : super(
          method: 'wallet_switchEthereumChain',
          paramsJson: jsonEncode({
            'chainId': chainInfo.chainId,
            'rpcUrls': [
              chainInfo.rpcUrl,
            ],
            'chainName': chainInfo.chainName,
            'nativeCurrency': {
              'name': chainInfo.tokenName,
              'symbol': chainInfo.tokenName,
              'decimals': 18,
            },
            'blockExplorerUrls': [
              chainInfo.blockExplorer?.url,
            ],
            'iconUrls': [
              chainInfo.chainIcon,
            ],
          }),
        );
}
