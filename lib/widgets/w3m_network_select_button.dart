import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/services/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/widgets/buttons/network_button.dart';

class W3MNetworkSelectButton extends StatefulWidget {
  const W3MNetworkSelectButton({
    super.key,
    required this.service,
    this.buttonRadius,
    this.width,
  });

  final IW3MService service;
  final double? buttonRadius;
  final double? width;

  @override
  State<W3MNetworkSelectButton> createState() => _W3MNetworkSelectButtonState();
}

class _W3MNetworkSelectButtonState extends State<W3MNetworkSelectButton> {
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
    return NetworkButton(
      service: widget.service,
      onTap: () => _onConnectPressed(context),
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
    debugPrint(
      'W3MNetworkSelectButton._onServiceUpdate(). isConnected: $_selectedChain.',
    );

    setState(() {
      _selectedChain = widget.service.selectedChain;
    });
  }
}
