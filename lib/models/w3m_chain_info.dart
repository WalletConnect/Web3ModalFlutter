import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/services/ledger_service.dart/ledger_service.dart';
import 'package:web3modal_flutter/services/ledger_service.dart/i_ledger_service.dart';

part 'w3m_chain_info.freezed.dart';

@freezed
class W3MChainInfo with _$W3MChainInfo {
  factory W3MChainInfo({
    required String chainName,
    required String chainId,
    required String namespace,
    required String chainIcon,
    required String tokenName,
    required Map<String, RequiredNamespace> requiredNamespaces,
    required Map<String, RequiredNamespace> optionalNamespaces,
    required String rpcUrl,
    BlockExplorer? blockExplorer,
    @Default(LedgerService()) ILedgerService ledgerService,
  }) = _W3MChainInfo;
}

@freezed
class BlockExplorer with _$BlockExplorer {
  factory BlockExplorer({
    required String name,
    required String url,
  }) = _BlockExplorer;
}
