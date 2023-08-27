import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/widgets/w3m_token_image.dart';

class W3MBalance extends StatefulWidget {
  static const balanceDefault = '_._';

  const W3MBalance({
    super.key,
    required this.service,
  });

  final IW3MService service;

  @override
  State<W3MBalance> createState() => _W3MBalanceState();
}

class _W3MBalanceState extends State<W3MBalance> {
  String? _tokenImage;
  String _balance = W3MBalance.balanceDefault;
  String? _tokenName;

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

    return Row(
      children: [
        // Token image
        W3MTokenImage(
          imageUrl: _tokenImage,
          size: 24,
        ),
        const SizedBox(width: 8.0),
        Text(
          _balance,
          style: TextStyle(
            color: themeData.foreground100,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        if (_tokenName != null)
          Row(
            children: [
              const SizedBox(width: 2.0),
              Text(
                _tokenName!,
                style: TextStyle(
                  color: themeData.foreground100,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _w3mServiceUpdated() {
    setState(() {
      _tokenImage = widget.service.tokenImageUrl;
      _balance = widget.service.chainBalance == null
          ? W3MBalance.balanceDefault
          : widget.service.chainBalance!.toStringAsPrecision(4);
      RegExp regex = RegExp(r"([.]*0+)(?!.*\d)");
      _balance = _balance.replaceAll(regex, '');
      _tokenName = widget.service.selectedChain == null
          ? null
          : widget.service.selectedChain!.tokenName;
    });
  }
}
