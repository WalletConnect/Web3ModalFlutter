import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/coinbase_service/coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_data.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_data.dart';
import 'package:web3modal_flutter/utils/w3m_chains_presets.dart';
import 'package:web3modal_flutter/utils/w3m_logger.dart';

enum W3MSessionService {
  wc,
  coinbase,
  magic,
  none;

  bool get isWC => this == W3MSessionService.wc;
  bool get isCoinbase => this == W3MSessionService.coinbase;
  bool get isMagic => this == W3MSessionService.magic;
  bool get noSession => this == W3MSessionService.none;
}

class W3MSession {
  SessionData? sessionData;
  CoinbaseData? coinbaseData;
  MagicData? magicData;

  W3MSession({
    this.sessionData,
    this.coinbaseData,
    this.magicData,
  });

  factory W3MSession.fromJson(Map<String, dynamic> json) {
    final sessionDataString = json['sessionData'];
    final coinbaseDataString = json['coinbaseData'];
    final magicDataString = json['magicData'];
    return W3MSession(
      sessionData: sessionDataString != null
          ? SessionData.fromJson(sessionDataString)
          : null,
      coinbaseData: coinbaseDataString != null
          ? CoinbaseData.fromJson(coinbaseDataString)
          : null,
      magicData:
          magicDataString != null ? MagicData.fromJson(magicDataString) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionData': sessionData?.toJson(),
      'coinbaseData': coinbaseData?.toJson(),
      'magicData': magicData?.toJson(),
    };
  }

  W3MSessionService get sessionService {
    if (sessionData != null) {
      return W3MSessionService.wc;
    }
    if (coinbaseData != null) {
      return W3MSessionService.coinbase;
    }
    if (magicData != null) {
      return W3MSessionService.magic;
    }

    return W3MSessionService.none;
  }

  String? get address {
    if (sessionService.noSession) {
      return null;
    }
    if (sessionService.isCoinbase) {
      return coinbaseData!.address;
    }
    if (sessionService.isMagic) {
      return magicData!.address;
    }
    final namespace = sessionData?.namespaces[StringConstants.namespace];
    final accounts = namespace?.accounts ?? [];
    if (accounts.isNotEmpty) {
      return NamespaceUtils.getAccount(accounts.first);
    }
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
    if (magicData != null) {
      return magicData!.chainId.toString();
    }

    return '1';
  }

  String? get connectedWalletName {
    if (coinbaseData != null) {
      return 'Coinbase Wallet';
    }
    if (magicData != null) {
      return 'Email Login';
    }
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
    if (sessionService.noSession) {
      return false;
    }
    if (sessionService.isCoinbase) {
      return true;
    }

    final nsMethods = getApprovedMethods() ?? [];
    final supportsAddChain = nsMethods.contains(
      MethodsConstants.walletAddEthChain,
    );
    return supportsAddChain;
  }

  List<String>? getApprovedMethods() {
    if (sessionService.noSession) {
      return null;
    }
    if (sessionService.isCoinbase) {
      return CoinbaseService.supportedMethods;
    }
    if (sessionService.isMagic) {
      return MagicService.supportedMethods;
    }

    final sessionNamespaces = sessionData!.namespaces;
    final namespace = sessionNamespaces[StringConstants.namespace];
    final methodsList = namespace?.methods.toSet().toList();
    return methodsList ?? [];
  }

  List<String>? getApprovedEvents() {
    if (sessionService.noSession) {
      return null;
    }
    if (sessionService.isCoinbase) {
      return [];
    }
    if (sessionService.isMagic) {
      return [];
    }

    final sessionNamespaces = sessionData!.namespaces;
    final namespace = sessionNamespaces[StringConstants.namespace];
    final eventsList = namespace?.events.toSet().toList();
    return eventsList ?? [];
  }

  List<String>? getApprovedChains() {
    if (sessionService.noSession) {
      return null;
    }
    // We can not know which chains are approved from Coinbase or Magic
    if (!sessionService.isWC) {
      return [chainId];
    }
    final accounts = getAccounts() ?? [];
    final approvedChains = NamespaceUtils.getChainsFromAccounts(accounts);
    return approvedChains;
  }

  List<String>? getAccounts() {
    if (sessionService.noSession) {
      return null;
    }
    if (sessionService.isCoinbase) {
      return ['${StringConstants.namespace}:$chainId:$address'];
    }
    if (sessionService.isMagic) {
      return ['${StringConstants.namespace}:$chainId:$address'];
    }

    final sessionNamespaces = sessionData!.namespaces;
    return sessionNamespaces[StringConstants.namespace]?.accounts ?? [];
  }

  Redirect? getSessionRedirect() {
    if (sessionService.noSession) {
      return null;
    }

    return sessionData?.peer.metadata.redirect;
  }
}
