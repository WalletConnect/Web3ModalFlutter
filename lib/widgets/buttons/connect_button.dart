import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';

enum ConnectButtonState {
  error,
  idle,
  disabled,
  connecting,
  connected,
  none,
}

class ConnectButton extends StatelessWidget {
  const ConnectButton({
    super.key,
    this.size = BaseButtonSize.regular,
    this.state = ConnectButtonState.idle,
    this.serviceStatus = W3MServiceStatus.idle,
    this.titleOverride,
    this.onTap,
  });
  final BaseButtonSize size;
  final ConnectButtonState state;
  final W3MServiceStatus serviceStatus;
  final String? titleOverride;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final connecting = state == ConnectButtonState.connecting;
    final disabled = state == ConnectButtonState.disabled;
    final connected = state == ConnectButtonState.connected;
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final borderRadius = radiuses.isSquare() ? 0.0 : size.height / 2;
    return BaseButton(
      onTap: disabled || connecting
          ? null
          : serviceStatus.isInitialized
              ? onTap
              : null,
      size: size,
      buttonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (connecting) {
              return themeColors.grayGlass010;
            }
            if (states.contains(MaterialState.disabled)) {
              return themeColors.grayGlass005;
            }
            return themeColors.accent100;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (connecting) {
              return themeColors.accent100;
            }
            if (states.contains(MaterialState.disabled)) {
              return themeColors.grayGlass015;
            }
            return themeColors.inverse100;
          },
        ),
        shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
          (states) {
            return RoundedRectangleBorder(
              side: (states.contains(MaterialState.disabled) || connecting)
                  ? BorderSide(color: themeColors.grayGlass010, width: 1.0)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(borderRadius),
            );
          },
        ),
      ),
      overridePadding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        connecting || serviceStatus.isLoading
            ? const EdgeInsets.only(left: 6.0, right: 16.0)
            : const EdgeInsets.only(left: 16.0, right: 16.0),
      ),
      child: connecting || serviceStatus.isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size.height * 0.7,
                  height: size.height * 0.7,
                  padding: const EdgeInsets.all(kPadding6),
                  child: CircularProgressIndicator(
                    color: themeColors.accent100,
                    strokeWidth: size == BaseButtonSize.small ? 1.0 : 1.5,
                  ),
                ),
                const SizedBox.square(dimension: 4.0),
                if (connecting)
                  Text(
                      titleOverride ?? StringConstants.connectButtonConnecting),
                if (serviceStatus.isLoading)
                  size == BaseButtonSize.small
                      ? Text(titleOverride ??
                          StringConstants.connectButtonIdleShort)
                      : Text(
                          titleOverride ?? StringConstants.connectButtonIdle),
              ],
            )
          : connected
              ? Text(titleOverride ?? StringConstants.connectButtonConnected)
              : size == BaseButtonSize.small
                  ? Text(
                      titleOverride ?? StringConstants.connectButtonIdleShort)
                  : Text(titleOverride ?? StringConstants.connectButtonIdle),
    );
  }
}
