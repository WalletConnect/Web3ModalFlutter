import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/widget_stack/widget_stack_singleton.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_button.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/widgets/w3m_token_image.dart';

class W3MNetworkSelect extends StatefulWidget {
  const W3MNetworkSelect({
    super.key,
    required this.service,
    this.buttonRadius,
  });

  final IW3MService service;
  final double? buttonRadius;

  @override
  State<W3MNetworkSelect> createState() => _W3MNetworkSelectState();
}

class _W3MNetworkSelectState extends State<W3MNetworkSelect> {
  static const double buttonHeight = 60;
  static const double buttonWidthMin = 150;
  static const double buttonWidthMax = 200;

  W3MChainInfo? _selectedChain;

  @override
  void initState() {
    super.initState();

    _onServiceUpdate();

    widget.service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    widget.service.removeListener(_onServiceUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: buttonHeight,
        minWidth: buttonWidthMin,
        maxWidth: buttonWidthMax,
      ),
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    final WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return WalletConnectModalButton(
      onPressed: () {
        _onConnectPressed(context);
      },
      borderRadius: widget.buttonRadius ?? themeData.radius4XS,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          W3MTokenImage(
            imageUrl: _selectedChain?.chainIcon == null
                ? null
                : explorerService.instance!.getAssetImageUrl(
                    imageId: _selectedChain!.chainIcon,
                  ),
            isChain: true,
          ),
          // _selectedChain?.chainIcon == null
          //     ? SvgPicture.asset(
          //         'assets/network_placeholder.svg',
          //         package: 'web3modal_flutter',
          //         width: 20,
          //         height: 20,
          //       )
          //     : Image.network(
          //         explorerService.instance!.getAssetImageUrl(
          //           imageId: _selectedChain!.chainIcon,
          //         ),
          //         width: 20,
          //         height: 20,
          //       ),
          const SizedBox(width: 8.0),
          Text(
            StringConstants.selectNetwork,
            style: TextStyle(
              color: Colors.white,
              fontFamily: themeData.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  void _onConnectPressed(BuildContext context) {
    widget.service.open(
      context: context,
      startWidget: SelectNetworkPage(
        onSelect: (info) {
          widget.service.setSelectedChain(info);
          widgetStack.instance.addDefault();
        },
      ),
    );
  }

  void _onServiceUpdate() {
    LoggerUtil.logger.i(
      'W3MNetworkSelect._onServiceUpdate(). isConnected: $_selectedChain.',
    );
    print('W3MNetworkSelect._onServiceUpdate(). isConnected: $_selectedChain.');

    setState(() {
      _selectedChain = widget.service.selectedChain;
    });
  }
}
