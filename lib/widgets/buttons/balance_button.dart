import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';

class BalanceButton extends StatefulWidget {
  static const balanceDefault = '_._';

  const BalanceButton({
    super.key,
    required this.service,
    this.size = BaseButtonSize.regular,
    this.onTap,
  });

  final IW3MService service;
  final BaseButtonSize size;
  final VoidCallback? onTap;

  @override
  State<BalanceButton> createState() => _BalanceButtonState();
}

class _BalanceButtonState extends State<BalanceButton> {
  String _balance = BalanceButton.balanceDefault;
  String? _tokenImage;
  String? _tokenName;

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

  void _w3mServiceUpdated() {
    setState(() {
      _tokenImage = widget.service.tokenImageUrl;
      _balance = coreUtils.instance.formatChainBalance(
        widget.service.chainBalance,
      );
      _tokenName = widget.service.selectedChain?.tokenName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    return BaseButton(
      size: widget.size,
      onTap: widget.onTap,
      buttonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeColors.grayGlass005;
            }
            return themeColors.grayGlass010;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeColors.grayGlass015;
            }
            return themeColors.foreground100;
          },
        ),
        shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
          (states) {
            return RoundedRectangleBorder(
              side: states.contains(MaterialState.disabled)
                  ? BorderSide(color: themeColors.grayGlass005, width: 1.0)
                  : BorderSide(color: themeColors.grayGlass010, width: 1.0),
              borderRadius: BorderRadius.circular(widget.size.height / 2),
            );
          },
        ),
      ),
      overridePadding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.only(
          left: 6.0,
          right: widget.size == BaseButtonSize.small ? 12.0 : 16.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundedIcon(
            imageUrl: _tokenImage,
            size: widget.size.height * 0.7,
          ),
          const SizedBox.square(dimension: 4.0),
          Text('$_balance ${_tokenName ?? ''}'),
        ],
      ),
    );
  }
}
