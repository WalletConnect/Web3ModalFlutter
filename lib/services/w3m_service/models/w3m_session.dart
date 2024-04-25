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
  SessionData? _sessionData;
  CoinbaseData? _coinbaseData;
  MagicData? _magicData;

  W3MSession({
    SessionData? sessionData,
    CoinbaseData? coinbaseData,
    MagicData? magicData,
  })  : _sessionData = sessionData,
        _coinbaseData = coinbaseData,
        _magicData = magicData;

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

  W3MSession copyWith({
    SessionData? sessionData,
    CoinbaseData? coinbaseData,
    MagicData? magicData,
  }) {
    return W3MSession(
      sessionData: sessionData ?? _sessionData,
      coinbaseData: coinbaseData ?? _coinbaseData,
      magicData: magicData ?? _magicData,
    );
  }

  W3MSessionService get sessionService {
    if (_sessionData != null) {
      return W3MSessionService.wc;
    }
    if (_coinbaseData != null) {
      return W3MSessionService.coinbase;
    }
    if (_magicData != null) {
      return W3MSessionService.magic;
    }

    return W3MSessionService.none;
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

    final sessionNamespaces = _sessionData!.namespaces;
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

    final sessionNamespaces = _sessionData!.namespaces;
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

    final sessionNamespaces = _sessionData!.namespaces;
    return sessionNamespaces[StringConstants.namespace]?.accounts ?? [];
  }

  Redirect? getSessionRedirect() {
    if (sessionService.noSession) {
      return null;
    }

    return _sessionData?.peer.metadata.redirect;
  }

  // toJson would convert W3MSession to a WCFV2 kind of session object
  Map<String, dynamic> toJson() {
    return {
      if (topic != null) 'topic': topic,
      if (pairingTopic != null) 'pairingTopic': pairingTopic,
      if (relay != null) 'relay': relay,
      if (expiry != null) 'expiry': expiry,
      if (acknowledged != null) 'acknowledged': acknowledged,
      if (controller != null) 'controller': controller,
      'namespaces': _namespaces(),
      if (requiredNamespaces != null) 'requiredNamespaces': requiredNamespaces,
      if (optionalNamespaces != null) 'optionalNamespaces': optionalNamespaces,
      'self': self?.toJson(),
      'peer': peer?.toJson(),
    };
  }
}

extension W3MSessionExtension on W3MSession {
  String? get topic => _sessionData?.topic;
  String? get pairingTopic => _sessionData?.pairingTopic;
  Relay? get relay => _sessionData?.relay;
  int? get expiry => _sessionData?.expiry;
  bool? get acknowledged => _sessionData?.acknowledged;
  String? get controller => _sessionData?.controller;
  Map<String, Namespace>? get namespaces => _sessionData?.namespaces;
  Map<String, RequiredNamespace>? get requiredNamespaces =>
      _sessionData?.requiredNamespaces;
  Map<String, RequiredNamespace>? get optionalNamespaces =>
      _sessionData?.optionalNamespaces;
  Map<String, String>? get sessionProperties => _sessionData?.sessionProperties;

  ConnectionMetadata? get self {
    if (sessionService.isCoinbase) {
      // return ConnectionMetadata(
      //   metadata: _sessionData?.self.metadata,
      //   publicKey: '',
      // );
    }
    if (sessionService.isMagic) {
      // return ConnectionMetadata(
      //   metadata: _sessionData?.self.metadata,
      //   publicKey: '',
      // );
    }
    return _sessionData?.self;
  }

  ConnectionMetadata? get peer {
    if (sessionService.isCoinbase) {
      return ConnectionMetadata(
        metadata: PairingMetadata(
          name: connectedWalletName!,
          description: '',
          url: '',
          icons: [],
          redirect: Redirect(
            native: CoinbaseService.coinbaseSchema,
          ),
        ),
        publicKey: '',
      );
    }
    if (sessionService.isMagic) {
      return ConnectionMetadata(
        metadata: PairingMetadata(
          name: connectedWalletName!,
          description: '',
          url: '',
          icons: [],
        ),
        publicKey: '',
      );
    }
    return _sessionData?.peer;
  }

  //
  String get email => _magicData?.email ?? '';

  //
  String? get address {
    if (sessionService.noSession) {
      return null;
    }
    if (sessionService.isCoinbase) {
      return _coinbaseData!.address;
    }
    if (sessionService.isMagic) {
      return _magicData!.address;
    }
    final namespace = namespaces?[StringConstants.namespace];
    final accounts = namespace?.accounts ?? [];
    if (accounts.isNotEmpty) {
      return NamespaceUtils.getAccount(accounts.first);
    }
    W3MLoggerUtil.logger.e('[$runtimeType] no address found');
    return null;
  }

  String get chainId {
    if (sessionService.isWC) {
      final chainIds = NamespaceUtils.getChainIdsFromNamespaces(
        namespaces: namespaces ?? {},
      );
      if (chainIds.isNotEmpty) {
        final chainId = (chainIds..sort()).first.split(':')[1];
        // If we have the chain in our presets, set it as the selected chain
        if (W3MChainPresets.chains.containsKey(chainId)) {
          return chainId;
        }
      }
    }
    if (sessionService.isCoinbase) {
      return _coinbaseData!.chainId.toString();
    }
    if (sessionService.isMagic) {
      return _magicData!.chainId.toString();
    }
    return '1';
  }

  String? get connectedWalletName {
    if (sessionService.isCoinbase) {
      return CoinbaseService.coinbaseWalletName;
    }
    if (sessionService.isMagic) {
      return 'Email Wallet';
    }
    if (sessionService.isWC) {
      return peer?.metadata.name;
    }
    return null;
  }

  Map<String, dynamic> toRawJson() {
    return {
      ...(_sessionData?.toJson() ?? {}),
      ...(_coinbaseData?.toJson() ?? {}),
      ...(_magicData?.toJson() ?? {}),
    };
  }

  Map<String, Namespace>? _namespaces() {
    if (sessionService.isCoinbase) {
      return {
        'eip155': Namespace(
          accounts: ['eip155:$chainId:$address'],
          methods: [...CoinbaseService.supportedMethods],
          events: [],
        ),
      };
    }
    if (sessionService.isMagic) {
      return {
        'eip155': Namespace(
          accounts: ['eip155:$chainId:$address'],
          methods: [...MagicService.supportedMethods],
          events: [],
        ),
      };
    }
    return namespaces;
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionData': _sessionData?.toJson(),
      'coinbaseData': _coinbaseData?.toJson(),
      'magicData': _magicData?.toJson(),
    };
  }
}
