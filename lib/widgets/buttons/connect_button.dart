import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
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
    this.titleOverride,
    this.onTap,
  });
  final BaseButtonSize size;
  final ConnectButtonState state;
  final String? titleOverride;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final textStyle = size == BaseButtonSize.small
        ? themeData.textStyles.small600
        : themeData.textStyles.paragraph600;
    final connecting = state == ConnectButtonState.connecting;
    final disabled = state == ConnectButtonState.disabled;
    final connected = state == ConnectButtonState.connected;
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final borderRadius = radiuses.isSquare() ? 0.0 : size.height / 2;
    return BaseButton(
      onTap: disabled || connecting ? null : onTap,
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
      child: connecting
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: (textStyle.fontSize ?? 20.0) * 0.8,
                  width: (textStyle.fontSize ?? 20.0) * 0.8,
                  child: CircularProgressIndicator(
                    color: themeColors.accent100,
                    strokeWidth: 2.0,
                  ),
                ),
                const SizedBox.square(dimension: 8.0),
                Text(titleOverride ?? StringConstants.connectButtonConnecting),
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
