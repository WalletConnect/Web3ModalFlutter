import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class W3MChainInfo {
  final String chainName;
  final String chainId;
  final String chainIcon;
  final String tokenName;
  final Map<String, RequiredNamespace> requiredNamespaces;

  const W3MChainInfo({
    required this.chainName,
    required this.chainId,
    required this.chainIcon,
    required this.tokenName,
    required this.requiredNamespaces,
  });
}

class W3MAssetIcon {
  final String icon;

  const W3MAssetIcon(this.icon);
}
