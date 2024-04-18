import 'package:flutter/material.dart';

import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/w3m_chains_presets.dart';

class AssetUtil {
  static String? getChainIconId(String chainId) {
    return W3MChainPresets.chainImagesId[chainId];
  }

  static String getThemedAsset(BuildContext context, String assetName) {
    if (Web3ModalTheme.maybeOf(context)?.isDarkMode == true) {
      return 'assets/dark/$assetName';
    }
    return 'assets/light/$assetName';
  }
}
