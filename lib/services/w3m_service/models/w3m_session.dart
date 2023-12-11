import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/constants/eth_constants.dart';
import 'package:web3modal_flutter/services/coinbase_service/coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_data.dart';
import 'package:web3modal_flutter/utils/w3m_chains_presets.dart';
import 'package:web3modal_flutter/utils/w3m_logger.dart';

enum W3MSessionService {
  wc,
  coinbase,
  magic,
  none,
}

class W3MSession {
  SessionData? sessionData;
  CoinbaseData? coinbaseData;
  // MagicData? magicData will be here

  W3MSession({
    this.sessionData,
    this.coinbaseData,
    // this.magicData,
  });

  factory W3MSession.fromJson(Map<String, dynamic> json) {
    final sessionDataString = json['sessionData'];
    final coinbaseDataString = json['coinbaseData'];
    // final magicDataString = json['magicData'];
    return W3MSession(
      sessionData: sessionDataString != null
          ? SessionData.fromJson(sessionDataString)
          : null,
      coinbaseData: coinbaseDataString != null
          ? CoinbaseData.fromJson(coinbaseDataString)
          : null,
      // magicData: magicDataString != null
      //     ? MagicData.fromJson(magicDataString)
      //     : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionData': sessionData?.toJson(),
      'coinbaseData': coinbaseData?.toJson(),
      // 'magicData': magicData?.toJson(),
    };
  }

  W3MSessionService get sessionService {
    if (sessionData != null) {
      return W3MSessionService.wc;
    }
    if (coinbaseData != null) {
      return W3MSessionService.coinbase;
    }
    // if (magicData != null)
    // return W3MSessionService.magic;
    //
    return W3MSessionService.none;
  }

  bool get hasSession => sessionService != W3MSessionService.none;

  String? get address {
    if (sessionData != null) {
      if (sessionData!.namespaces.isNotEmpty) {
        final accounts = sessionData!.namespaces.values.first.accounts;
        if (accounts.isNotEmpty) {
          return NamespaceUtils.getAccount(accounts.first);
        }
        W3MLoggerUtil.logger.e('[$runtimeType] empty accounts');
      }
    }
    if (coinbaseData != null) {
      return coinbaseData!.address;
    }
    // if (magicData != null)
    //
    W3MLoggerUtil.logger.e('[$runtimeType] no address found');
    return null;
  }

  String get chainId {
    if (sessionData != null) {
      final chainIds = NamespaceUtils.getChainIdsFromNamespaces(
        namespaces: sessionData!.namespaces,
      );
      if (chainIds.isNotEmpty) {
        final chainId = (chainIds..sort()).first.split(':')[1];
        // If we have the chain in our presets, set it as the selected chain
        if (W3MChainPresets.chains.containsKey(chainId)) {
          return chainId;
        }
      }
    }
    if (coinbaseData != null) {
      return coinbaseData!.chainId.toString();
    }
    // if (magicData != null)
    //
    return '1';
  }

  String? get connectedWalletName {
    if (coinbaseData != null) {
      return 'Coinbase Wallet';
    }
    // if (magicData != null)
    //
    if (sessionData != null) {
      return sessionData!.peer.metadata.name;
    }
    return null;
  }

  String? get topic {
    if (sessionData != null) {
      return sessionData!.topic;
    }
    return null;
  }

  bool hasSwitchMethod() {
    if (sessionData == null) {
      return false;
    }
    final nsMethods = getApprovedMethods() ?? [];
    final supportsAddChain = nsMethods.contains(EthConstants.walletAddEthChain);

    return supportsAddChain;
  }

  List<String>? getApprovedMethods() {
    if (!hasSession) {
      return null;
    }
    if (sessionService == W3MSessionService.coinbase) {
      return CoinbaseService.approvedMethods;
    }

    final sessionNamespaces = sessionData!.namespaces;
    return sessionNamespaces[EthConstants.namespace]?.methods ?? [];
  }

  // bool isChainApproved(String chainId) {
  //   if (sessionData == null) {
  //     // TODO check this if has to be true
  //     return false;
  //   }
  //   return NamespaceUtils.getChainIdsFromNamespaces(
  //     namespaces: sessionData!.namespaces,
  //   ).contains(chainId);
  // }

  List<String>? getApprovedChains() {
    if (!hasSession) {
      return null;
    }
    if (sessionService != W3MSessionService.wc) {
      return [chainId];
    }
    final accounts = getAccounts() ?? [];
    final approvedChains = NamespaceUtils.getChainsFromAccounts(accounts);

    return approvedChains;
  }

  List<String>? getAccounts() {
    if (!hasSession) {
      return null;
    }
    if (sessionService == W3MSessionService.coinbase) {
      return ['${EthConstants.namespace}:$chainId:$address'];
    }

    final sessionNamespaces = sessionData!.namespaces;
    return sessionNamespaces[EthConstants.namespace]?.accounts ?? [];
  }

  Redirect? getSessionRedirect() {
    if (coinbaseData != null) {
      return Redirect(native: 'cbwallet://wsegue');
    }
    // if (magicData != null)
    //
    if (sessionData != null) {
      final metadata = sessionData!.peer.metadata;
      return metadata.redirect;
    }
    return null;
  }
}
