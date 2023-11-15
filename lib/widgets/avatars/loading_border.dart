import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

class LoadingBorder extends StatefulWidget {
  const LoadingBorder({
    super.key,
    required this.child,
    this.padding = 16.0,
    this.strokeWidth = 4.0,
    this.borderRadius = 0.0,
    this.animate = true,
  });
  final Widget child;
  final double padding;
  final double strokeWidth;
  final double borderRadius;
  final bool animate;

  @override
  State<LoadingBorder> createState() => _LoadingBorderState();
}

class _LoadingBorderState extends State<LoadingBorder>
    with TickerProviderStateMixin {
  //
  late AnimationController _controller;
  late Animation<double> _tweenAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _tweenAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant LoadingBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.animate) {
      _controller.stop();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: kSelectedWalletIconHeight + widget.padding,
          width: kSelectedWalletIconHeight + widget.padding,
          child: CustomPaint(
            painter: _CircularBorderPainter(
              borderRadius: widget.borderRadius,
              frontColor: themeColors.accent100,
              strokeWidth: widget.strokeWidth,
            ),
            child: RotationTransition(
              turns: _tweenAnimation,
              child: CustomPaint(
                painter: _CircularBorderPainter2(
                  show: widget.animate,
                  backColor: themeColors.background125,
                ),
              ),
            ),
          ),
        ),
        SizedBox.square(
          dimension: kSelectedWalletIconHeight,
          child: widget.child,
        ),
      ],
    );
  }
}

class _CircularBorderPainter extends CustomPainter {
  const _CircularBorderPainter({
    required this.frontColor,
    required this.strokeWidth,
    this.borderRadius = 32.0,
  });
  final Color frontColor;
  final double strokeWidth, borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final paint2 = Paint()
      ..strokeWidth = strokeWidth
      ..color = frontColor
      ..style = PaintingStyle.stroke;

    final rect1 = Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width: w * 0.95,
      height: h * 0.95,
    );

    final rrect1 = RRect.fromRectAndRadius(
      rect1,
      Radius.circular(borderRadius + 4.0),
    );
    canvas.drawRRect(rrect1, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CircularBorderPainter2 extends CustomPainter {
  const _CircularBorderPainter2({
    required this.backColor,
    this.show = true,
  });
  final Color backColor;
  final bool show;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final paint1 = Paint()
      ..color = backColor
      ..style = PaintingStyle.fill;

    final rect2 = Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width: w * 1.4,
      height: h * 1.4,
    );

    canvas.drawArc(
      rect2,
      0,
      show ? math.pi * 1.5 : math.pi * 2,
      true,
      paint1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
