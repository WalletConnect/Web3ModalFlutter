import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';

class NetworkButton extends StatelessWidget {
  const NetworkButton({
    super.key,
    this.size = BaseButtonSize.regular,
    this.serviceStatus = W3MServiceStatus.idle,
    this.chainInfo,
    this.onTap,
  });
  final W3MChainInfo? chainInfo;
  final BaseButtonSize size;
  final W3MServiceStatus serviceStatus;
  final VoidCallback? onTap;

  String _getImageUrl(W3MChainInfo chainInfo) {
    if (chainInfo.chainIcon != null && chainInfo.chainIcon!.contains('http')) {
      return chainInfo.chainIcon!;
    }
    final chainImageId = AssetUtil.getChainIconId(chainInfo.chainId);
    return explorerService.instance!.getAssetImageUrl(chainImageId);
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final imageUrl = chainInfo != null ? _getImageUrl(chainInfo!) : null;
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final borderRadius = radiuses.isSquare() ? 0.0 : size.height / 2;
    return BaseButton(
      size: size,
      onTap: serviceStatus.isInitialized ? onTap : null,
      buttonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeColors.grayGlass005;
            }
            return themeColors.grayGlass010;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeColors.grayGlass015;
            }
            return themeColors.foreground100;
          },
        ),
        shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
          (states) {
            return RoundedRectangleBorder(
              side: states.contains(MaterialState.disabled)
                  ? BorderSide(color: themeColors.grayGlass005, width: 1.0)
                  : BorderSide(color: themeColors.grayGlass010, width: 1.0),
              borderRadius: BorderRadius.circular(borderRadius),
            );
          },
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          serviceStatus.isLoading
              ? Container(
                  width: size.height * 0.7,
                  height: size.height * 0.7,
                  padding: const EdgeInsets.all(kPadding6),
                  child: CircularProgressIndicator(
                    color: themeColors.accent100,
                    strokeWidth: size == BaseButtonSize.small ? 1.0 : 1.5,
                  ),
                )
              : RoundedIcon(
                  assetPath: 'assets/icons/network.svg',
                  imageUrl: imageUrl,
                  size: size.height * 0.7,
                  assetColor: themeColors.inverse100,
                  padding: size == BaseButtonSize.small ? 5.0 : 6.0,
                ),
          const SizedBox.square(dimension: 4.0),
          Text(
            chainInfo?.chainName ??
                (size == BaseButtonSize.small
                    ? StringConstants.selectNetworkShort
                    : StringConstants.selectNetwork),
          ),
        ],
      ),
      overridePadding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.only(left: 6.0, right: 16.0),
      ),
    );
  }
}
