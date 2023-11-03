import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/toast/toast_message.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils_singleton.dart';

class WalletConnectModalToast extends StatefulWidget {
  const WalletConnectModalToast({
    super.key,
    required this.message,
  });

  final ToastMessage message;

  @override
  State<WalletConnectModalToast> createState() =>
      _WalletConnectModalToastState();
}

class _WalletConnectModalToastState extends State<WalletConnectModalToast>
    with SingleTickerProviderStateMixin {
  static const fadeInTime = 200;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: fadeInTime),
      vsync: this,
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward().then((_) {
      Future.delayed(
        widget.message.duration - const Duration(milliseconds: fadeInTime * 2),
      ).then((_) {
        if (!mounted) {
          return;
        }
        _controller.reverse().then((value) => toastUtils.instance.clear());
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    return Positioned(
      top: 10.0,
      left: 20.0,
      right: 20.0,
      child: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: themeColors.background175,
              borderRadius: BorderRadius.circular(radiuses.radiusM),
              border: Border.all(
                color: themeColors.grayGlass005,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.message.icon(context),
                  const SizedBox(width: 8.0),
                  Text(
                    widget.message.text,
                    textAlign: TextAlign.center,
                    style: themeData.textStyles.paragraph500.copyWith(
                      color: themeColors.foreground100,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
