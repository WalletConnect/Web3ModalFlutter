import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:web3modal_flutter/services/web3modal/i_web3modal_service.dart';
import 'package:web3modal_flutter/utils/logger_util.dart';
import 'package:web3modal_flutter/widgets/web3modal_theme.dart';

enum Web3ModalConnectButtonState {
  idle,
  connecting,
  account,
}

class Web3ModalConnect extends StatefulWidget {
  const Web3ModalConnect({
    super.key,
    required this.web3ModalService,
    this.buttonRadius,
  });

  final IWeb3ModalService web3ModalService;
  final double? buttonRadius;

  @override
  State<Web3ModalConnect> createState() => _Web3ModalConnectState();
}

class _Web3ModalConnectState extends State<Web3ModalConnect> {
  static const double buttonHeight = 60;
  static const double buttonWidthMin = 150;
  static const double buttonWidthMax = 200;

  Web3ModalConnectButtonState _state = Web3ModalConnectButtonState.idle;

  @override
  void initState() {
    super.initState();

    _updateState();

    widget.web3ModalService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    widget.web3ModalService.removeListener(_onServiceUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: buttonHeight,
        minWidth: buttonWidthMin,
        maxWidth: buttonWidthMax,
      ),
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    final Web3ModalTheme theme = Web3ModalTheme.of(context);

    if (_state == Web3ModalConnectButtonState.idle) {
      return MaterialButton(
        onPressed: () => _onConnectPressed(context),
        color: theme.data.primary100,
        focusColor: theme.data.primary090,
        hoverColor: theme.data.primary090,
        highlightColor: theme.data.primary080,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            widget.buttonRadius ?? theme.data.radius4XS,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/walletconnect_logo_white.svg',
              width: 20,
              height: 20,
              package: 'web3modal_flutter',
              colorFilter: ColorFilter.mode(
                theme.data.foreground100,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              'Connect Wallet',
              style: TextStyle(
                color: theme.data.foreground100,
                fontFamily: theme.data.fontFamily,
              ),
            ),
          ],
        ),
      );
    } else if (_state == Web3ModalConnectButtonState.connecting) {
      return MaterialButton(
        onPressed: () {},
        color: theme.data.overlay030,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            widget.buttonRadius ?? theme.data.radius4XS,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: theme.data.primary100,
            ),
            const SizedBox(width: 8.0),
            Text(
              'Connecting...',
              style: TextStyle(
                color: theme.data.foreground100,
                fontFamily: theme.data.fontFamily,
              ),
            ),
          ],
        ),
      );
    } else if (_state == Web3ModalConnectButtonState.account) {
      return MaterialButton(
        onPressed: _onAccountPressed,
        color: theme.data.primary100,
        focusColor: theme.data.primary090,
        hoverColor: theme.data.primary090,
        highlightColor: theme.data.primary080,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            widget.buttonRadius ?? theme.data.radius4XS,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image.network(
            //   'https://placeholder.com/icon1.png',
            // ),
            Text(
              'Disconnect',
              style: TextStyle(
                color: theme.data.foreground100,
                fontFamily: theme.data.fontFamily,
              ),
            ),
          ],
        ),
      );
    }

    return Container();
  }

  void _onConnectPressed(BuildContext context) {
    widget.web3ModalService.open(context: context);
  }

  void _onAccountPressed() {
    // widget.web3ModalService.open(
    //   context: context,
    //   startState: Web3ModalState.account,
    // );
    widget.web3ModalService.disconnect();
  }

  void _onServiceUpdate() {
    LoggerUtil.logger.i(
      'Web3ModalConnectButton._onServiceUpdate(). isConnected: ${widget.web3ModalService.isConnected}, isOpen: ${widget.web3ModalService.isOpen}',
    );

    _updateState();
  }

  void _updateState() {
    // Case 1: Is connected
    if (widget.web3ModalService.isConnected) {
      setState(() {
        _state = Web3ModalConnectButtonState.account;
      });
      return;
    }
    // Case 2: Is not open and is not connected
    else if (!widget.web3ModalService.isOpen &&
        !widget.web3ModalService.isConnected) {
      setState(() {
        _state = Web3ModalConnectButtonState.idle;
      });
      return;
    }
    // Case 3: Is open and is not connected
    else if (widget.web3ModalService.isOpen &&
        !widget.web3ModalService.isConnected) {
      setState(() {
        _state = Web3ModalConnectButtonState.connecting;
      });
      return;
    }
  }
}
