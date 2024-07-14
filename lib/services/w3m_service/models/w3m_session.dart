import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/coinbase_service/coinbase_service.dart';
import 'package:web3modal_flutter/services/coinbase_service/models/coinbase_data.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_data.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

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
  SIWESession? _siweSession;

  W3MSession({
    SessionData? sessionData,
    CoinbaseData? coinbaseData,
    MagicData? magicData,
    SIWESession? siweSession,
  })  : _sessionData = sessionData,
        _coinbaseData = coinbaseData,
        _magicData = magicData,
        _siweSession = siweSession;

  /// USED TO READ THE SESSION FROM LOCAL STORAGE
  factory W3MSession.fromMap(Map<String, dynamic> map) {
    final sessionDataString = map['sessionData'];
    final coinbaseDataString = map['coinbaseData'];
    final magicDataString = map['magicData'];
    final siweSession = map['siweSession'];
    return W3MSession(
      sessionData: sessionDataString != null
          ? SessionData.fromJson(sessionDataString)
          : null,
      coinbaseData: coinbaseDataString != null
          ? CoinbaseData.fromJson(coinbaseDataString)
          : null,
      magicData:
          magicDataString != null ? MagicData.fromJson(magicDataString) : null,
      siweSession:
          siweSession != null ? SIWESession.fromJson(siweSession) : null,
    );
  }

  W3MSession copyWith({
    SessionData? sessionData,
    CoinbaseData? coinbaseData,
    MagicData? magicData,
    SIWESession? siweSession,
  }) {
    return W3MSession(
      sessionData: sessionData ?? _sessionData,
      coinbaseData: coinbaseData ?? _coinbaseData,
      magicData: magicData ?? _magicData,
      siweSession: siweSession ?? _siweSession,
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

  // toJson() would convert W3MSession to a SessionData kind of map
  // no matter if Coinbase Wallet or Email Wallet is connected
  Map<String, dynamic> toJson() => {
        if (topic != null) 'topic': topic,
        if (pairingTopic != null) 'pairingTopic': pairingTopic,
        if (relay != null) 'relay': relay,
        if (expiry != null) 'expiry': expiry,
        if (acknowledged != null) 'acknowledged': acknowledged,
        if (controller != null) 'controller': controller,
        'namespaces': _namespaces(),
        if (requiredNamespaces != null)
          'requiredNamespaces': requiredNamespaces,
        if (optionalNamespaces != null)
          'optionalNamespaces': optionalNamespaces,
        'self': self?.toJson(),
        'peer': peer?.toJson(),
      };
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
      return _coinbaseData?.self;
    }
    if (sessionService.isMagic) {
      return _magicData?.self;
    }
    return _sessionData?.self;
  }

  ConnectionMetadata? get peer {
    if (sessionService.isCoinbase) {
      return _coinbaseData?.peer;
    }
    if (sessionService.isMagic) {
      return _magicData?.peer;
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
      return CoinbaseService.defaultWalletData.listing.name;
    }
    if (sessionService.isMagic) {
      return MagicService.defaultWalletData.listing.name;
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
          chains: ['eip155:$chainId'],
          accounts: ['eip155:$chainId:$address'],
          methods: [...CoinbaseService.supportedMethods],
          events: [],
        ),
      };
    }
    if (sessionService.isMagic) {
      return {
        'eip155': Namespace(
          chains: ['eip155:$chainId'],
          accounts: ['eip155:$chainId:$address'],
          methods: [...MagicService.supportedMethods],
          events: [],
        ),
      };
    }
    return namespaces;
  }

  /// USED TO STORE THE SESSION IN LOCAL STORAGE
  Map<String, dynamic> toMap() {
    return {
      if (_sessionData != null) 'sessionData': _sessionData!.toJson(),
      if (_coinbaseData != null) 'coinbaseData': _coinbaseData?.toJson(),
      if (_magicData != null) 'magicData': _magicData?.toJson(),
      if (_siweSession != null) 'siweSession': _siweSession?.toJson(),
    };
  }
}
