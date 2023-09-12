import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/chain_data.dart';

class AssetUtil {
  static String getChainIconAssetId(String chainId) {
    return ChainData.chainPresets[chainId]?.chainIcon ??
        '692ed6ba-e569-459a-556a-776476829e00';
  }

  static String getTokenIconAssetId(String tokenName) {
    return ChainData.tokenPresets[tokenName]?.icon ??
        '692ed6ba-e569-459a-556a-776476829e00';
  }

  static String getThemedAsset(BuildContext context, String assetName) {
    if (Web3ModalTheme.maybeOf(context)?.isDarkMode == true) {
      return 'assets/dark/$assetName';
    }
    return 'assets/light/$assetName';
  }
}
