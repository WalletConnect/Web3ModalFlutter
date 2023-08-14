import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';

class W3MConnectedChip extends StatefulWidget {
  const W3MConnectedChip({
    super.key,
    required this.service,
  });

  final IW3MService service;

  @override
  State<W3MConnectedChip> createState() => _W3MConnectedChipState();
}

class _W3MConnectedChipState extends State<W3MConnectedChip> {
  bool _connected = false;

  @override
  void initState() {
    super.initState();

    widget.service.addListener(_service_updated);
    _connected = widget.service.isConnected;
  }

  @override
  void dispose() {
    widget.service.removeListener(_service_updated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return Container(
      decoration: BoxDecoration(
        color: themeData.overlay030,
        border: Border.all(
          color: themeData.overlay010,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      constraints: const BoxConstraints(
        minWidth: 150,
        maxWidth: 250,
      ),
      child: Row(
        children: [
          // The glowing dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _connected ? themeData.success : themeData.error,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: _connected ? themeData.success : themeData.error,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          // Connected Text
          Text(
            _connected ? StringConstants.connected : StringConstants.error,
          ),
        ],
      ),
    );
  }

  void _service_updated() {
    setState(() {
      _connected = widget.service.isConnected;
    });
  }
}
