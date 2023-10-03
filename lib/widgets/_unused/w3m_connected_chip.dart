import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

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
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Container(
      decoration: BoxDecoration(
        color: themeColors.background200,
        border: Border.all(
          color: themeColors.grayGlass010,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      constraints: const BoxConstraints(
        minWidth: 50,
        maxWidth: 250,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The glowing dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _connected ? themeColors.success100 : themeColors.error100,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: _connected
                      ? themeColors.success100
                      : themeColors.error100,
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
            style: TextStyle(
              color: themeColors.foreground100,
              fontFamily: themeData.textStyles.fontFamily,
            ),
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
