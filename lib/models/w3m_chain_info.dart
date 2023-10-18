import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

part 'w3m_chain_info.freezed.dart';

@freezed
class W3MChainInfo with _$W3MChainInfo {
  factory W3MChainInfo({
    required String chainName,
    required String chainId,
    required String namespace,
    String? chainIcon,
    required String tokenName,
    required Map<String, RequiredNamespace> requiredNamespaces,
    required Map<String, RequiredNamespace> optionalNamespaces,
    required String rpcUrl,
    W3MBlockExplorer? blockExplorer,
  }) = _W3MChainInfo;
}

@freezed
class W3MBlockExplorer with _$W3MBlockExplorer {
  factory W3MBlockExplorer({
    required String name,
    required String url,
  }) = _W3MBlockExplorer;
}
