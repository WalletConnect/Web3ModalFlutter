import 'package:flutter/material.dart';
import 'package:web3modal_flutter/pages/account_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';
import 'package:web3modal_flutter/widgets/buttons/balance_button.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_account_avatar.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';

class W3MAccountButton extends StatefulWidget {
  const W3MAccountButton({
    super.key,
    required this.service,
    this.size = BaseButtonSize.regular,
    this.avatar,
  });

  final IW3MService service;
  final BaseButtonSize size;
  final String? avatar;

  @override
  State<W3MAccountButton> createState() => _W3MAccountButtonState();
}

class _W3MAccountButtonState extends State<W3MAccountButton> {
  String? _address;
  String? _tokenImage;
  String _balance = BalanceButton.balanceDefault;
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
      _address = widget.service.address;
      _tokenImage = widget.service.tokenImageUrl;
      _balance = BalanceButton.balanceDefault;
      if (widget.service.chainBalance != null) {
        _balance = widget.service.chainBalance!.toStringAsPrecision(4);
        _balance = _balance.replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
      }
      _tokenName = widget.service.selectedChain?.tokenName;
    });
  }

  void _onTap() => widget.service.openModal(context, const AccountPage());

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final textStyle = widget.size == BaseButtonSize.small
        ? themeData.textStyles.small600
        : themeData.textStyles.paragraph600;
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final borderRadius = radiuses.isSquare() ? 0.0 : widget.size.height / 2;
    final innerBorderRadius =
        radiuses.isSquare() ? 0.0 : BaseButtonSize.small.height / 2;
    // TODO this button should be able to be disable by passing a null onTap action
    // I should decouple an AccountButton from W3MAccountButton like on ConnectButton and NetworkButton
    return BaseButton(
      size: widget.size,
      onTap: widget.service.status.isInitialized ? _onTap : null,
      overridePadding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.only(left: 4.0, right: 4.0),
      ),
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
            return themeColors.foreground175;
          },
        ),
        shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
          (states) {
            return RoundedRectangleBorder(
              side: states.contains(MaterialState.disabled)
                  ? BorderSide(color: themeColors.grayGlass005, width: 1.0)
                  : BorderSide(color: themeColors.grayGlass010, width: 1.0),
              borderRadius: BorderRadius.circular(borderRadius),
            );
          },
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BalanceButton(
            isLoading: widget.service.status.isLoading,
            balance: _balance,
            tokenName: _tokenName,
            tokenImage: _tokenImage,
            iconSize: widget.size.iconSize + 4.0,
            buttonSize: widget.size,
            onTap: _onTap,
          ),
          const SizedBox.square(dimension: 4.0),
          Padding(
            padding: EdgeInsets.only(
              top: widget.size == BaseButtonSize.small ? 4.0 : 0.0,
              bottom: widget.size == BaseButtonSize.small ? 4.0 : 0.0,
            ),
            child: BaseButton(
              size: BaseButtonSize.small,
              onTap: _onTap,
              overridePadding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                EdgeInsets.only(
                  left: widget.size == BaseButtonSize.small ? 4.0 : 6.0,
                  right: 8.0,
                ),
              ),
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
                    return themeColors.foreground175;
                  },
                ),
                shape:
                    MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
                  (states) {
                    return RoundedRectangleBorder(
                      side: states.contains(MaterialState.disabled)
                          ? BorderSide(
                              color: themeColors.grayGlass005,
                              width: 1.0,
                            )
                          : BorderSide(
                              color: themeColors.grayGlass010,
                              width: 1.0,
                            ),
                      borderRadius: BorderRadius.circular(innerBorderRadius),
                    );
                  },
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.size.iconSize),
                      border: Border.all(
                        color: themeColors.grayGlass005,
                        width: 1.0,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: W3MAccountAvatar(
                      service: widget.service,
                      size: widget.size.iconSize,
                      disabled: false,
                    ),
                  ),
                  const SizedBox.square(dimension: 4.0),
                  Text(
                    Util.truncate(
                      _address ?? '',
                      length: widget.size == BaseButtonSize.small ? 2 : 4,
                    ),
                    style: textStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceButton extends StatelessWidget {
  const _BalanceButton({
    required this.onTap,
    required this.isLoading,
    required this.balance,
    required this.tokenName,
    required this.tokenImage,
    required this.iconSize,
    required this.buttonSize,
  });
  final VoidCallback? onTap;
  final bool isLoading;
  final String balance;
  final String? tokenName;
  final String? tokenImage;
  final double iconSize;
  final BaseButtonSize buttonSize;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final themeData = Web3ModalTheme.getDataOf(context);
    final textStyle = buttonSize == BaseButtonSize.small
        ? themeData.textStyles.small600
        : themeData.textStyles.paragraph600;
    return BaseButton(
      size: BaseButtonSize.small,
      onTap: onTap,
      overridePadding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.only(left: 2.0),
      ),
      buttonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeColors.grayGlass015;
            }
            return themeColors.foreground100;
          },
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              : RoundedIcon(
                  imageUrl: tokenImage,
                  size: iconSize,
                ),
          const SizedBox.square(dimension: 4.0),
          Text(
            '$balance ${tokenName ?? ''}',
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
