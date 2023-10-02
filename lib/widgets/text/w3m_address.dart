import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/util.dart';

class W3MAddress extends StatefulWidget {
  const W3MAddress({
    super.key,
    required this.service,
    this.style,
  });

  final IW3MService service;
  final TextStyle? style;

  @override
  State<W3MAddress> createState() => _W3MAddressState();
}

class _W3MAddressState extends State<W3MAddress> {
  String? _address;

  @override
  void initState() {
    super.initState();
    _w3mServiceUpdated();
    widget.service.addListener(_w3mServiceUpdated);
  }

  @override
  void dispose() {
    widget.service.removeListener(_w3mServiceUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Text(
      Util.truncate(_address ?? ''),
      style: widget.style ??
          themeData.textStyles.paragraph600.copyWith(
            color: themeColors.foreground100,
          ),
    );
  }

  void _w3mServiceUpdated() {
    setState(() {
      _address = widget.service.address;
    });
  }
}
