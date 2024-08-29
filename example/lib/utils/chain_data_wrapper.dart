import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_dapp/models/chain_metadata.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class ChainDataWrapper {
  static final List<ChainMetadata> _chains = [
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.blue,
      w3mChainInfo: W3MChainPresets.chains['1']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.cyan,
      w3mChainInfo: W3MChainPresets.chains['42161']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.purple,
      w3mChainInfo: W3MChainPresets.chains['137']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.red.shade300,
      w3mChainInfo: W3MChainPresets.chains['43114']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.yellow.shade600,
      w3mChainInfo: W3MChainPresets.chains['56']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.red.shade900,
      w3mChainInfo: W3MChainPresets.chains['10']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.green.shade900,
      w3mChainInfo: W3MChainPresets.chains['100']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.purple.shade50,
      w3mChainInfo: W3MChainPresets.chains['324']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.blue.shade100,
      w3mChainInfo: W3MChainPresets.chains['8453']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.yellow,
      w3mChainInfo: W3MChainPresets.chains['42220']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.green.shade100,
      w3mChainInfo: W3MChainPresets.chains['1313161554']!,
    ),
    ChainMetadata(
      type: ChainType.solana,
      color: Colors.purple.shade400,
      w3mChainInfo: W3MChainPresets.chains['5eykt4UsFv8P8NJdTREpY1vzqKqZKvdp']!,
    ),
    // ChainMetadata(
    //   type: ChainType.kadena,
    //   chainId: 'kadena:mainnet01',
    //   name: 'Kadena',
    //   logo: 'TODO',
    //   color: Colors.purple.shade600,
    //   rpc: [
    //     "https://api.testnet.chainweb.com",
    //   ],
    // ),
  ];
}

ChainMetadata getChainMetadataFromChain(String namespace) {
  try {
    return ChainDataWrapper._chains
        .where((element) => element.w3mChainInfo.namespace == namespace)
        .first;
  } catch (_) {
    return ChainMetadata(
      color: Colors.blue,
      type: ChainType.eip155,
      w3mChainInfo: W3MChainPresets.chains.values.firstWhere(
        (e) => e.namespace == namespace,
      ),
    );
  }
}
