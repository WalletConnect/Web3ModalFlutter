import 'package:flutter/material.dart';

import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/services/analytics_service/analytics_service_singleton.dart';
import 'package:web3modal_flutter/services/analytics_service/models/analytics_event.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';
import 'package:web3modal_flutter/widgets/buttons/network_button.dart';

class W3MNetworkSelectButton extends StatefulWidget {
  const W3MNetworkSelectButton({
    super.key,
    required this.service,
    this.size = BaseButtonSize.regular,
    this.context,
    this.custom,
  });

  final IW3MService service;
  final BaseButtonSize size;
  final BuildContext? context;
  final Widget? custom;

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
    widget.service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.custom ??
        NetworkButton(
          serviceStatus: widget.service.status,
          chainInfo: _selectedChain,
          size: widget.size,
          onTap: () => _onConnectPressed(),
        );
  }

  void _onConnectPressed() {
    analyticsService.instance.sendEvent(ClickNetworksEvent());
    if (widget.service.modalContext != null) {
      widget.service.openModalView(
        SelectNetworkPage(
          onTapNetwork: (info) {
            widget.service.selectChain(info);
            widgetStack.instance.addDefault();
          },
        ),
      );
    } else {
      // TODO remove this once context parameter is enforced
      // ignore: deprecated_member_use_from_same_package
      widget.service.openModal(
        widget.context ?? context,
        SelectNetworkPage(
          onTapNetwork: (info) {
            widget.service.selectChain(info);
            widgetStack.instance.addDefault();
          },
        ),
      );
    }
  }

  void _onServiceUpdate() {
    setState(() {
      _selectedChain = widget.service.selectedChain;
    });
  }
}
