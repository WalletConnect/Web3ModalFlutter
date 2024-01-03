import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_dapp/models/chain_metadata.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/chain_data_wrapper.dart';
import 'package:web3modal_flutter/utils/w3m_chains_presets.dart';

String getChainName(String chain) {
  try {
    return ChainDataWrapper.chains
        .where((element) => element.w3mChainInfo.namespace == chain)
        .first
        .w3mChainInfo
        .chainName;
  } catch (e) {
    debugPrint('getChainName, Invalid chain: $chain');
  }
  return 'Unknown';
}

ChainMetadata getChainMetadataFromChain(String namespace) {
  try {
    return ChainDataWrapper.chains
        .where((element) => element.w3mChainInfo.namespace == namespace)
        .first;
  } catch (_) {
    return ChainMetadata(
      color: Colors.grey,
      type: ChainType.eip155,
      w3mChainInfo: W3MChainPresets.chains.values.firstWhere(
        (e) => e.namespace == namespace,
      ),
    );
  }
}
