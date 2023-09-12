import 'package:flutter/material.dart';

import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
// import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/theme.dart';
// import 'package:web3modal_flutter/utils/logger.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';
import 'package:web3modal_flutter/widgets/w3m_token_image.dart';

import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';

class NetworkButton extends StatefulWidget {
  const NetworkButton({
    super.key,
    // required this.service,
    this.size = BaseButtonSize.regular,
    this.chainInfo,
    this.onTap,
  });
  // final IW3MService service;
  final W3MChainInfo? chainInfo;
  final BaseButtonSize size;
  final VoidCallback? onTap;

  @override
  State<NetworkButton> createState() => _NetworkButtonState();
}

class _NetworkButtonState extends State<NetworkButton> {
  // W3MChainInfo? _selectedChain;

  @override
  void initState() {
    super.initState();
    // _w3mServiceUpdated();
    // widget.service.addListener(_w3mServiceUpdated);
  }

  @override
  void dispose() {
    super.dispose();
    // widget.service.removeListener(_w3mServiceUpdated);
  }

  // void _w3mServiceUpdated() {
  //   LoggerUtil.logger.i(
  //     'W3MNetworkSelectButton._onServiceUpdate(). isConnected: $_selectedChain.',
  //   );
  //   setState(() {
  //     _selectedChain = widget.service.selectedChain;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return BaseButton(
      size: widget.size,
      onTap: widget.onTap,
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
              borderRadius: BorderRadius.circular(widget.size.height / 2),
            );
          },
        ),
      ),
      icon: W3MTokenImage(
        imageUrl: widget.chainInfo?.chainIcon == null
            ? null
            : explorerService.instance!.getAssetImageUrl(
                imageId: widget.chainInfo!.chainIcon,
              ),
        isChain: true,
        size: widget.size.height - 12.0,
        disabled: widget.onTap == null,
      ),
      child: Text(
        widget.chainInfo?.chainName ??
            (widget.size == BaseButtonSize.small
                ? StringConstants.selectNetworkShort
                : StringConstants.selectNetwork),
      ),
    );
  }
}
