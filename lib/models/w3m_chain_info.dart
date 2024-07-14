import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

part 'w3m_chain_info.freezed.dart';

@freezed
class W3MChainInfo with _$W3MChainInfo {
  factory W3MChainInfo({
    required String chainName,
    required String chainId,
    required String namespace,
    required String tokenName,
    required String rpcUrl,
    @Default(<String>[]) List<String> extraRpcUrls,
    String? chainIcon,
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

class W3MNamespace {
  const W3MNamespace({
    this.chains,
    required this.methods,
    required this.events,
  });

  final List<String>? chains;
  final List<String> methods;
  final List<String> events;
}

extension W3MNamespaceExtension on W3MNamespace {
  RequiredNamespace toRequired() {
    return RequiredNamespace(
      chains: chains,
      methods: methods,
      events: events,
    );
  }
}

extension W3MChainInfoExtension on W3MChainInfo {
  String get chainHexId => '0x${int.parse(chainId).toRadixString(16)}';

  Map<String, dynamic> toJson() {
    return {
      'chainId': chainHexId,
      'chainName': chainName,
      'nativeCurrency': {
        'name': tokenName,
        'symbol': tokenName,
        'decimals': 18,
      },
      'rpcUrls': [
        rpcUrl,
        ...extraRpcUrls,
      ],
      if (blockExplorer != null && blockExplorer!.url.isNotEmpty)
        'blockExplorerUrls': [
          blockExplorer!.url,
        ],
    };
  }
}
