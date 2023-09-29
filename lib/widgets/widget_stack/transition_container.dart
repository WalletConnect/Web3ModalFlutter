import 'package:flutter/material.dart';

// TODO change transition type to reflect Web implementation
class TransitionContainer extends StatefulWidget {
  const TransitionContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<TransitionContainer> createState() => _TransitionContainerState();
}

class _TransitionContainerState extends State<TransitionContainer>
    with TickerProviderStateMixin {
  static const fadeDuration = Duration(milliseconds: 200);
  static const resizeDuration = Duration(milliseconds: 150);
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Widget _oldChild;

  @override
  void initState() {
    super.initState();

    _oldChild = widget.child;

    _fadeController = AnimationController(
      vsync: this,
      duration: fadeDuration,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      _fadeController,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(
      _fadeController,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    // _resizeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TransitionContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child.key != widget.child.key) {
      _fadeController.forward().then((_) {
        setState(() {
          _oldChild = widget.child;
        });
        Future.delayed(
          resizeDuration - const Duration(milliseconds: 50),
        ).then((value) {
          if (mounted) {
            _fadeController.reverse();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (BuildContext context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: AnimatedSize(
              duration: resizeDuration,
              child: _oldChild,
            ),
          ),
        );
      },
    );
  }
}
