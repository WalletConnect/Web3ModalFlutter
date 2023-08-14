import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/widgets/w3m_token_image.dart';

class W3MBalance extends StatefulWidget {
  const W3MBalance({
    super.key,
    required this.service,
  });

  final IW3MService service;

  @override
  State<W3MBalance> createState() => _W3MBalanceState();
}

class _W3MBalanceState extends State<W3MBalance> {
  static const balanceDefault = '_._';

  String? _tokenImage;
  String _balance = balanceDefault;
  String? _tokenName;

  @override
  void initState() {
    super.initState();

    widget.service.addListener(_w3m_service_updated);
    _w3m_service_updated();
  }

  @override
  void dispose() {
    widget.service.removeListener(_w3m_service_updated);
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
          token: _tokenImage,
        ),
        const SizedBox(width: 2.0),
        Text(
          _balance,
          style: TextStyle(
            color: themeData.foreground100,
            fontWeight: FontWeight.bold,
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
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _w3m_service_updated() {
    setState(() {
      _tokenImage = widget.service.tokenImageUrl;
      _balance = widget.service.chainBalance == null
          ? balanceDefault
          : widget.service.chainBalance!.toStringAsFixed(3);
      _tokenName = widget.service.selectedChain == null
          ? null
          : widget.service.selectedChain!.tokenName;
    });
  }
}
