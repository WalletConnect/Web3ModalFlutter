import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/services/ledger_service.dart/ethereum_service.dart';
import 'package:web3modal_flutter/services/ledger_service.dart/i_ledger_service.dart';

class W3MChainInfo {
  final String chainName;
  final String chainId;
  final String chainIcon;
  final String tokenName;
  final Map<String, RequiredNamespace> requiredNamespaces;
  final String rpcUrl;
  final ILedgerService ledgerService;

  const W3MChainInfo({
    required this.chainName,
    required this.chainId,
    required this.chainIcon,
    required this.tokenName,
    required this.requiredNamespaces,
    required this.rpcUrl,
    this.ledgerService = const EVMService(),
  });
}

class W3MAssetIcon {
  final String icon;

  const W3MAssetIcon(this.icon);
}
