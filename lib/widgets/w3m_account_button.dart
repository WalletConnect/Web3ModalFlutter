import 'package:flutter/material.dart';
import 'package:web3modal_flutter/pages/approve_magic_request_page.dart';
import 'package:web3modal_flutter/pages/confirm_email_page.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_events.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/buttons/balance_button.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_account_avatar.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';
import 'package:web3modal_flutter/widgets/loader.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';

class W3MAccountButton extends StatefulWidget {
  const W3MAccountButton({
    super.key,
    required this.service,
    this.size = BaseButtonSize.regular,
    this.avatar,
    this.context,
    this.custom,
  });

  final IW3MService service;
  final BaseButtonSize size;
  final String? avatar;
  final BuildContext? context;
  final Widget? custom;

  @override
  State<W3MAccountButton> createState() => _W3MAccountButtonState();
}

class _W3MAccountButtonState extends State<W3MAccountButton> {
  String _balance = BalanceButton.balanceDefault;
  String _address = '';
  String? _tokenImage;
  String? _tokenName;

  @override
  void initState() {
    super.initState();
    _w3mServiceUpdated();
    widget.service.addListener(_w3mServiceUpdated);
    // TODO [W3MAccountButton] this should go in W3MService but for that, init() method of W3MService should receive a BuildContext, which would be a breaking change
    magicService.instance.onMagicRpcRequest.subscribe(_approveSign);
    magicService.instance.onMagicLoginRequest.subscribe(_loginRequested);
  }

  @override
  void dispose() {
    widget.service.removeListener(_w3mServiceUpdated);
    magicService.instance.onMagicRpcRequest.unsubscribe(_approveSign);
    magicService.instance.onMagicLoginRequest.unsubscribe(_loginRequested);
    super.dispose();
  }

  void _w3mServiceUpdated() {
    setState(() {
      _address = widget.service.session?.address ?? '';
      final chainId = widget.service.selectedChain?.chainId ?? '';
      final imageId = AssetUtil.getChainIconId(chainId) ?? '';
      _tokenImage = explorerService.instance.getAssetImageUrl(imageId);
      _balance = widget.service.chainBalance;
      _tokenName = widget.service.selectedChain?.tokenName;
    });
  }

  void _onTap() {
    if (widget.service.modalContext != null) {
      widget.service.openModalView();
    } else {
      // TODO remove this once context parameter is enforced
      // ignore: deprecated_member_use_from_same_package
      widget.service.openModal(widget.context ?? context);
    }
  }

  void _approveSign(MagicRequestEvent? args) async {
    if (args?.request != null) {
      if (widget.service.isOpen) {
        widgetStack.instance.push(ApproveTransactionPage());
      } else {
        if (widget.service.modalContext != null) {
          widget.service.openModalView(ApproveTransactionPage());
        } else {
          // TODO remove this once context parameter is enforced
          // ignore: deprecated_member_use_from_same_package
          widget.service.openModal(
            widget.context ?? context,
            ApproveTransactionPage(),
          );
        }
      }
    }
  }

  void _loginRequested(MagicSessionEvent? args) {
    if (widget.service.isOpen) {
      widgetStack.instance.popAllAndPush(ConfirmEmailPage());
    } else {
      if (widget.service.modalContext != null) {
        widget.service.openModalView(ConfirmEmailPage());
      } else {
        // TODO remove this once context parameter is enforced
        // ignore: deprecated_member_use_from_same_package
        widget.service.openModal(widget.context ?? context, ConfirmEmailPage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.custom != null) {
      return widget.custom!;
    }
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final borderRadius = radiuses.isSquare() ? 0.0 : widget.size.height / 2;
    final enabled = _address.isNotEmpty && widget.service.status.isInitialized;
    // TODO [W3MAccountButton] this button should be able to be disable by passing a null onTap action
    // I should decouple an AccountButton from W3MAccountButton like on ConnectButton and NetworkButton
    return BaseButton(
      size: widget.size,
      onTap: enabled ? _onTap : null,
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
            iconSize: widget.size.iconSize,
            buttonSize: widget.size,
            onTap: enabled ? _onTap : null,
          ),
          const SizedBox.square(dimension: 4.0),
          _AddressButton(
            address: _address,
            buttonSize: widget.size,
            service: widget.service,
            onTap: enabled ? _onTap : null,
          ),
        ],
      ),
    );
  }
}

class _AddressButton extends StatelessWidget {
  const _AddressButton({
    required this.buttonSize,
    required this.address,
    required this.service,
    required this.onTap,
  });
  final BaseButtonSize buttonSize;
  final VoidCallback? onTap;
  final String address;
  final IW3MService service;

  @override
  Widget build(BuildContext context) {
    if (address.isEmpty) {
      return SizedBox.shrink();
    }
    final themeData = Web3ModalTheme.getDataOf(context);
    final textStyle = buttonSize == BaseButtonSize.small
        ? themeData.textStyles.small600
        : themeData.textStyles.paragraph600;
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final innerBorderRadius =
        radiuses.isSquare() ? 0.0 : BaseButtonSize.small.height / 2;
    return Padding(
      padding: EdgeInsets.only(
        top: buttonSize == BaseButtonSize.small ? 4.0 : 0.0,
        bottom: buttonSize == BaseButtonSize.small ? 4.0 : 0.0,
      ),
      child: BaseButton(
        size: BaseButtonSize.small,
        onTap: onTap,
        overridePadding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.only(
            left: buttonSize == BaseButtonSize.small ? 4.0 : 6.0,
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
          shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
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
                borderRadius: BorderRadius.circular(buttonSize.iconSize),
                border: Border.all(
                  color: themeColors.grayGlass005,
                  width: 1.0,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: W3MAccountAvatar(
                service: service,
                size: buttonSize.iconSize,
                disabled: false,
              ),
            ),
            const SizedBox.square(dimension: 4.0),
            Text(
              Util.truncate(
                address,
                length: buttonSize == BaseButtonSize.small ? 2 : 4,
              ),
              style: textStyle,
            ),
          ],
        ),
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
              ? Row(
                  children: [
                    const SizedBox.square(dimension: kPadding6),
                    CircularLoader(
                      size: 16.0,
                      strokeWidth: 1.5,
                    ),
                    const SizedBox.square(dimension: kPadding6),
                  ],
                )
              : (tokenImage ?? '').isEmpty
                  ? RoundedIcon(
                      assetPath: 'assets/icons/network.svg',
                      size: iconSize,
                      assetColor: themeColors.inverse100,
                      padding: 4.0,
                    )
                  : RoundedIcon(
                      imageUrl: tokenImage,
                      size: iconSize + 2.0,
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
