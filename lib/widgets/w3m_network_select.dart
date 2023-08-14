import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';

class W3MNetworkSelect extends StatefulWidget {
  const W3MNetworkSelect({
    super.key,
    required this.w3mService,
    this.buttonRadius,
  });

  final IW3MService w3mService;
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

    widget.w3mService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    widget.w3mService.removeListener(_onServiceUpdate);
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
    final WalletConnectModalTheme theme = WalletConnectModalTheme.of(context);

    return MaterialButton(
      onPressed: () => _onConnectPressed(context),
      color: theme.data.primary100,
      focusColor: theme.data.primary090,
      hoverColor: theme.data.primary090,
      highlightColor: theme.data.primary080,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          widget.buttonRadius ?? theme.data.radius4XS,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _selectedChain?.chainIcon == null
              ? SvgPicture.asset(
                  'assets/network_placeholder.svg',
                  width: 20,
                  height: 20,
                )
              : Image.network(
                  explorerService.instance!.getAssetImageUrl(
                    imageId: _selectedChain!.chainIcon,
                  ),
                  width: 20,
                  height: 20,
                ),
          const SizedBox(width: 8.0),
          Text(
            StringConstants.selectNetwork,
            style: TextStyle(
              color: theme.data.foreground100,
              fontFamily: theme.data.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  void _onConnectPressed(BuildContext context) {
    widget.w3mService.open(
      context: context,
      startWidget: const SelectNetworkPage(),
    );
  }

  void _onServiceUpdate() {
    LoggerUtil.logger.i(
      'W3MNetworkSelect._onServiceUpdate(). isConnected: $_selectedChain.',
    );

    setState(() {
      _selectedChain = widget.w3mService.selectedChain;
    });
  }
}
