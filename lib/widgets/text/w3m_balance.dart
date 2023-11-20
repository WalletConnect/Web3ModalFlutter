import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/widgets/buttons/balance_button.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';

class W3MBalanceText extends StatefulWidget {
  const W3MBalanceText({
    super.key,
    this.size = BaseButtonSize.regular,
    this.onTap,
  });

  final BaseButtonSize size;
  final VoidCallback? onTap;

  @override
  State<W3MBalanceText> createState() => _W3MBalanceTextState();
}

class _W3MBalanceTextState extends State<W3MBalanceText> {
  String _balance = BalanceButton.balanceDefault;
  String? _tokenName;
  IW3MService? _service;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _service = Web3ModalProvider.of(context).service;
      _w3mServiceUpdated();
      _service?.addListener(_w3mServiceUpdated);
    });
  }

  @override
  void dispose() {
    _service?.removeListener(_w3mServiceUpdated);
    super.dispose();
  }

  void _w3mServiceUpdated() {
    if (_service == null) return;
    setState(() {
      _balance = coreUtils.instance.formatChainBalance(
        _service!.chainBalance,
      );
      _tokenName = _service?.selectedChain?.tokenName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Text(
      '$_balance ${_tokenName ?? ''}',
      style: themeData.textStyles.paragraph500.copyWith(
        color: themeColors.foreground200,
      ),
    );
  }
}
