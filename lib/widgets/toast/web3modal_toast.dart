import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/toast/toast_message.dart';

class Web3ModalToast extends StatefulWidget {
  const Web3ModalToast({
    super.key,
    required this.message,
  });

  final ToastMessage message;

  @override
  State<Web3ModalToast> createState() => _Web3ModalToastState();
}

class _Web3ModalToastState extends State<Web3ModalToast>
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
        widget.message.duration -
            const Duration(
              milliseconds: fadeInTime * 2,
            ),
      ).then((_) {
        _controller.reverse();
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
    return Positioned(
      top: 20.0,
      left: 20.0,
      right: 20.0,
      child: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: widget.message.type == ToastType.info
                  ? Colors.grey.shade800
                  : Colors.red,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.message.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
