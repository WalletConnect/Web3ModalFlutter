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
    this.width,
  });

  final IW3MService service;
  final double? buttonRadius;
  final double? width;

  @override
  State<W3MNetworkSelect> createState() => _W3MNetworkSelectState();
}

class _W3MNetworkSelectState extends State<W3MNetworkSelect> {
  static const double _defaultButtonRadius = 10;

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
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 40,
          minWidth: widget.width ?? 180,
        ),
        child: _buildButton(context),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return WalletConnectModalButton(
      onPressed: () {
        _onConnectPressed(context);
      },
      borderRadius: widget.buttonRadius ?? _defaultButtonRadius,
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
            size: 30,
          ),
          const SizedBox(width: 8.0),
          Text(
            widget.service.selectedChain?.chainName ??
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
