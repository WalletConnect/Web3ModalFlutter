import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/models/w3m_chains_presets.dart';

class AssetUtil {
  static String getChainIconAssetId(String chainId) {
    return W3MChainPresets.chains[chainId]?.chainIcon ??
        '692ed6ba-e569-459a-556a-776476829e00';
  }

  static String getTokenIconAssetId(String tokenName) {
    return W3MChainPresets.chains.values
            .firstWhereOrNull((element) => element.tokenName == tokenName)
            ?.chainIcon ??
        '692ed6ba-e569-459a-556a-776476829e00';
  }

  static String getThemedAsset(BuildContext context, String assetName) {
    if (Web3ModalTheme.maybeOf(context)?.isDarkMode == true) {
      return 'assets/dark/$assetName';
    }
    return 'assets/light/$assetName';
  }
}
