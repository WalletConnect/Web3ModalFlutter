import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
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

    widget.service.addListener(_w3mServiceUpdated);
    _w3mServiceUpdated();
  }

  @override
  void dispose() {
    widget.service.removeListener(_w3mServiceUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return Text(
      // _address ?? '',
      Util.truncate(_address ?? ''),
      style: widget.style ??
          TextStyle(
            color: themeData.foreground100,
          ),
      // overflow: TextOverflow.ellipsis,
      // maxLines: 1,
      // softWrap: false,
    );
  }

  void _w3mServiceUpdated() {
    setState(() {
      _address = widget.service.address;
    });
  }
}
