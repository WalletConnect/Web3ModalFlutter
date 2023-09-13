import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';
import 'package:web3modal_flutter/widgets/w3m_token_image.dart';

import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';

class NetworkButton extends StatelessWidget {
  const NetworkButton({
    super.key,
    this.size = BaseButtonSize.regular,
    this.chainInfo,
    this.onTap,
  });
  final W3MChainInfo? chainInfo;
  final BaseButtonSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return BaseButton(
      size: size,
      onTap: onTap,
      buttonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeData.colors.overgray005;
            }
            return themeData.colors.overgray010;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeData.colors.overgray015;
            }
            return themeData.colors.foreground100;
          },
        ),
        shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
          (states) {
            return RoundedRectangleBorder(
              side: states.contains(MaterialState.disabled)
                  ? BorderSide(color: themeData.colors.overgray005, width: 1.0)
                  : BorderSide(color: themeData.colors.overgray010, width: 1.0),
              borderRadius: BorderRadius.circular(size.height / 2),
            );
          },
        ),
      ),
      icon: W3MTokenImage(
        imageUrl: chainInfo?.chainIcon == null
            ? null
            : explorerService.instance!.getAssetImageUrl(
                imageId: chainInfo!.chainIcon,
              ),
        isChain: true,
        size: size.height - 12.0,
        disabled: onTap == null,
      ),
      child: Text(
        chainInfo?.chainName ??
            (size == BaseButtonSize.small
                ? StringConstants.selectNetworkShort
                : StringConstants.selectNetwork),
      ),
    );
  }
}
