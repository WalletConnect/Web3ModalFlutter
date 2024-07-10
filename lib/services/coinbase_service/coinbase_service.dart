import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:web3modal_flutter/models/listing.dart';

import 'package:web3modal_flutter/services/coinbase_service/i_coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_data.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_events.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/logger_service/logger_service_singleton.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:coinbase_wallet_sdk/currency.dart';
import 'package:coinbase_wallet_sdk/action.dart';
import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk.dart';
import 'package:coinbase_wallet_sdk/configuration.dart';
import 'package:coinbase_wallet_sdk/eth_web3_rpc.dart';
import 'package:coinbase_wallet_sdk/request.dart';

class CoinbaseService implements ICoinbaseService {
  static const coinbasePackageName = 'org.toshi';
  static const defaultWalletData = W3MWalletInfo(
    listing: Listing(
      id: 'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa',
      name: 'Coinbase Wallet',
      homepage: 'https://www.coinbase.com/wallet/',
      imageId: 'a5ebc364-8f91-4200-fcc6-be81310a0000',
      order: 4110,
      mobileLink: 'cbwallet://wsegue',
      appStore: 'https://apps.apple.com/app/apple-store/id1278383455',
      playStore: 'https://play.google.com/store/apps/details?id=org.toshi',
      // rdns: 'com.coinbase.wallet',
    ),
    installed: false,
    recent: false,
  );

  String _iconImage = '';

  @override
  ConnectionMetadata get metadata => ConnectionMetadata(
        metadata: PairingMetadata(
          name: _walletData.listing.name,
          description: '',
          url: _walletData.listing.homepage,
          icons: [
            _iconImage,
          ],
          redirect: Redirect(
            native: _walletData.listing.mobileLink,
            universal: _walletData.listing.webappLink,
          ),
        ),
        publicKey: '',
      );

  static const supportedMethods = [
    ...MethodsConstants.requiredMethods,
    'eth_requestAccounts',
    'eth_signTypedData_v3',
    'eth_signTypedData_v4',
    'eth_signTransaction',
    MethodsConstants.walletSwitchEthChain,
    MethodsConstants.walletAddEthChain,
    'wallet_watchAsset',
  ];

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

  late final PairingMetadata _metadata;
  late bool _enabled;
  late W3MWalletInfo _walletData;

  CoinbaseService({
    required PairingMetadata metadata,
    bool enabled = false,
  })  : _metadata = metadata,
        _enabled = enabled;

  @override
  Future<void> init() async {
    if (!_enabled) return;
    // Configure SDK for each platform

    _walletData = (await explorerService.instance.getCoinbaseWalletObject()) ??
        defaultWalletData;
    final imageId = defaultWalletData.listing.imageId;
    _iconImage = explorerService.instance.getWalletImageUrl(imageId);

    final universal = _metadata.redirect?.universal ?? '';
    final nativeLink = _metadata.redirect?.native ?? '';
    final walletLink = _walletData.listing.mobileLink ?? '';
    if ((universal.isNotEmpty && nativeLink.isNotEmpty) ||
        walletLink.isNotEmpty) {
      try {
        final config = Configuration(
          ios: IOSConfiguration(
            host: Uri.parse(walletLink),
            callback: Uri.parse(nativeLink),
          ),
          android: AndroidConfiguration(
            domain: Uri.parse(universal),
          ),
        );
        await CoinbaseWalletSDK.shared.configure(config);
      } catch (_) {
        // Silent error
      }
    } else {
      _enabled = false;
      throw W3MCoinbaseException('Initialization error');
    }
  }

  @override
  Future<String> get ownPublicKey async {
    try {
      return await CoinbaseWalletSDK.shared.ownPublicKey();
    } catch (e) {
      loggerService.instance.e('[$runtimeType] ownPublicKey $e');
      return '';
    }
  }

  @override
  Future<String> get peerPublicKey async {
    try {
      return await CoinbaseWalletSDK.shared.peerPublicKey();
    } catch (e) {
      loggerService.instance.e('[$runtimeType] peerPublicKey $e');
      return '';
    }
  }

  @override
  Future<void> getAccount() async {
    await _checkInstalled();
    try {
      final results = await CoinbaseWalletSDK.shared.initiateHandshake([
        const RequestAccounts(),
      ]);
      final result = results.first;
      if (result.error != null) {
        final errorCode = result.error?.code;
        final errorMessage = result.error!.message;
        onCoinbaseError.broadcast(CoinbaseErrorEvent(errorMessage));
        throw W3MCoinbaseException('$errorMessage ($errorCode)');
      }

      final data = CoinbaseData.fromJson(result.account!.toJson()).copytWith(
        peer: metadata.copyWith(
          publicKey: await peerPublicKey,
        ),
        self: ConnectionMetadata(
          metadata: _metadata,
          publicKey: await ownPublicKey,
        ),
      );
      onCoinbaseConnect.broadcast(CoinbaseConnectEvent(data));
      return;
    } on PlatformException catch (e, s) {
      // Currently Coinbase SDK is not differentiate between User rejection or any other kind of error in iOS
      final errorMessage = (e.message ?? '').toLowerCase();
      onCoinbaseError.broadcast(CoinbaseErrorEvent(errorMessage));
      throw W3MCoinbaseException(errorMessage, e, s);
    } catch (e, s) {
      onCoinbaseError.broadcast(CoinbaseErrorEvent('Initial handshake error'));
      throw W3MCoinbaseException('Initial handshake error', e, s);
    }
  }

  @override
  Future<dynamic> request({
    required String chainId,
    required SessionRequestParams request,
  }) async {
    await _checkInstalled();
    final cid = chainId.contains(':') ? chainId.split(':').last : chainId;
    try {
      final req = Request(actions: [request.toCoinbaseRequest(cid)]);
      final result = (await CoinbaseWalletSDK.shared.makeRequest(req)).first;
      if (result.error != null) {
        final errorCode = result.error?.code;
        final errorMessage = result.error!.message;
        onCoinbaseError.broadcast(CoinbaseErrorEvent(errorMessage));
        throw W3MCoinbaseException('$errorMessage ($errorCode)');
      }
      final value = result.value?.replaceAll('"', '');
      switch (req.actions.first.method) {
        case 'wallet_switchEthereumChain':
        case 'wallet_addEthereumChain':
          final event = CoinbaseSessionEvent(chainId: cid);
          onCoinbaseSessionUpdate.broadcast(event);
          break;
        case 'eth_requestAccounts':
          final json = jsonDecode(value!);
          final data = CoinbaseData.fromJson(json).copytWith(
            peer: metadata.copyWith(
              publicKey: await peerPublicKey,
            ),
            self: ConnectionMetadata(
              metadata: _metadata,
              publicKey: await ownPublicKey,
            ),
          );
          onCoinbaseConnect.broadcast(CoinbaseConnectEvent(data));
          break;
        default:
          onCoinbaseResponse.broadcast(CoinbaseResponseEvent(data: value));
          break;
      }
      return value;
    } on W3MCoinbaseException catch (e) {
      onCoinbaseError.broadcast(CoinbaseErrorEvent(e.message));
      rethrow;
    } on PlatformException catch (e, s) {
      final message = 'Coinbase Wallet Error: (${e.code}) ${e.message}';
      onCoinbaseError.broadcast(CoinbaseErrorEvent(message));
      throw W3MCoinbaseException(message, e, s);
    }
  }

  @override
  Future<bool> isInstalled() async {
    try {
      return await CoinbaseWalletSDK.shared.isAppInstalled();
    } catch (e, s) {
      throw W3MCoinbaseException('Check is installed error', e, s);
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      return await CoinbaseWalletSDK.shared.isConnected();
    } catch (e, s) {
      throw W3MCoinbaseException('Check is connected error', e, s);
    }
  }

  @override
  Future<void> resetSession() async {
    try {
      return CoinbaseWalletSDK.shared.resetSession();
    } catch (e, s) {
      throw W3MCoinbaseException('Reset session error', e, s);
    }
  }

  Future<bool> _checkInstalled() async {
    final installed = await isInstalled();
    if (!installed) {
      throw W3MCoinbaseNotInstalledException();
    }
    return true;
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
      case MethodsConstants.ethSendTransaction:
        BigInt? weiValue;
        final jsonData = _getTransactionFromParams(params);
        if (jsonData.containsKey('value')) {
          final hexValue = jsonData['value'].toString().replaceFirst('0x', '');
          final value = int.parse(hexValue, radix: 16);
          weiValue = BigInt.from(value);
        }
        final data = jsonData['data']?.toString();
        if (method == 'eth_signTransaction') {
          return SignTransaction(
            fromAddress: jsonData['from'].toString(),
            toAddress: jsonData['to'].toString(),
            chainId: chainId!,
            weiValue: weiValue,
            data: data,
          );
        }
        return SendTransaction(
          fromAddress: jsonData['from'].toString(),
          toAddress: jsonData['to'].toString(),
          chainId: chainId!,
          weiValue: weiValue,
          data: data,
        );
      case MethodsConstants.walletSwitchEthChain:
      case MethodsConstants.walletAddEthChain:
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
        } catch (e, s) {
          throw W3MCoinbaseException('Unrecognized chainId $chainId', e, s);
        }
      case 'wallet_watchAsset':
        final address = _getAddressFromParamsList(params);
        final symbol = _getDataFromParamsList(params);
        return WatchAsset(
          address: address,
          symbol: symbol,
        );
      default:
        throw W3MCoinbaseException('Unsupported request method $method');
    }
  }

  // TODO [CoinbaseService] this should be an utils on WCFV2
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
