import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_dapp/models/chain_metadata.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class ChainDataWrapper {
  static final List<ChainMetadata> chains = [
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.blue.shade300,
      w3mChainInfo: W3MChainPresets.chains['1']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.purple.shade300,
      w3mChainInfo: W3MChainPresets.chains['137']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.purple.shade900,
      w3mChainInfo: W3MChainPresets.chains['42161']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.red.shade400,
      w3mChainInfo: W3MChainPresets.chains['43114']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.yellow.shade600,
      w3mChainInfo: W3MChainPresets.chains['56']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: const Color(0xFF123962),
      w3mChainInfo: W3MChainPresets.chains['250']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.red.shade700,
      w3mChainInfo: W3MChainPresets.chains['10']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.blue.shade800,
      w3mChainInfo: W3MChainPresets.chains['9001']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.purple.shade800,
      w3mChainInfo: W3MChainPresets.chains['4689']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.purple.shade700,
      w3mChainInfo: W3MChainPresets.chains['1088']!,
    ),
    // const ChainMetadata(
    //   type: ChainType.solana,
    //   chainId: 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
    //   name: 'Solana',
    //   logo: 'TODO',
    //   color: Colors.black,
    //   rpc: [
    //     "https://solana-api.projectserum.com",
    //   ],
    // ),
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
