import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_dapp/models/chain_metadata.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/chain_data_wrapper.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/eip155.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/solana_data.dart';

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
  } catch (e) {
    debugPrint('getChainMetadataFromChain, Invalid chain: $namespace');
  }
  return ChainDataWrapper.chains[0];
}

List<String> getChainMethods(ChainType value) {
  if (value == ChainType.solana) {
    return SolanaData.methods.values.toList();
  } else if (value == ChainType.kadena) {
    return EIP155.methods.values.toList(); //Kadena.methods.values.toList();
  } else {
    return EIP155.methods.values.toList();
  }
}

List<String> getChainEvents(ChainType value) {
  if (value == ChainType.solana) {
    return SolanaData.events.values.toList();
  } else if (value == ChainType.kadena) {
    return EIP155.events.values.toList(); //Kadena.events.values.toList();
  } else {
    return EIP155.events.values.toList();
  }
}
