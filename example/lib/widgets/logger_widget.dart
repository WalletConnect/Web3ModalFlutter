import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:web3modal_flutter/services/logger_service/logger_service_singleton.dart';

class DraggableCard extends StatefulWidget {
  final OverlayController overlayController;
  const DraggableCard({
    super.key,
    required this.overlayController,
  });

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  final List<Widget> _logs = [];
  //
  @override
  void initState() {
    super.initState();
    loggerService.instance.logEvents.listen((event) {
      final message = '${event.message}';
      if (message.contains('sendEvent')) {
        final match = RegExp(r'::([^]*?)::').firstMatch(message)?[1];
        if (match != null) {
          final json = jsonDecode(match.trim()) as Map<String, dynamic>;
          final data = json['props'];
          _logs.add(
            Text(
              '=> $data',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
          );
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    widget.overlayController.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Card(
      elevation: 6.0,
      color: Colors.black87,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 200.0,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 200.0,
                child: ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(6.0),
                  children: _logs.reversed.toList(),
                ),
              ),
            ),
            GestureDetector(
              onPanUpdate: (details) {
                widget.overlayController.alignChildTo(
                  details.globalPosition,
                  size * 0.5,
                );
              },
              onPanEnd: (_) {
                // overlayController.alignToScreenEdge();
              },
              child: Container(
                width: 25.0,
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OverlayController extends AnimatedOverlay {
  OverlayController(super.duration);

  OverlayEntry? _entry;

  Alignment align = Alignment.centerRight;

  Animation<Alignment>? alignAnimation;

  OverlayEntry createAlignOverlay(Widget child) {
    return OverlayEntry(
      maintainState: true,
      builder: (_) {
        return CustomAlign(
          animation: alignAnimation ?? AlwaysStoppedAnimation(align),
          child: child,
        );
      },
    );
  }

  void insert(BuildContext context) {
    _entry = createAlignOverlay(DraggableCard(overlayController: this));
    Overlay.of(context).insert(_entry!);
  }

  void toggle(BuildContext context) {
    if (_entry != null) {
      remove();
    } else {
      insert(context);
    }
  }

  void remove() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }

  void alignChildTo(Offset globalPosition, Size size) {
    double dx = (globalPosition.dx - size.width) / size.width;
    double dy = (globalPosition.dy - size.height) / size.height;

    dx = dx.abs() < 1 ? dx : dx / dx.abs();
    dy = dy.abs() < 1 ? dy : dy / dy.abs();

    final newAlign = Alignment(dx, dy);

    if (align == newAlign) return;

    alignAnimation = createAnimation(begin: align, end: newAlign);

    align = newAlign;

    controller.forward();
    _entry?.markNeedsBuild();
  }
}

abstract class AnimatedOverlay extends TickerProvider {
  @override
  Ticker createTicker(onTick) => Ticker(onTick);

  late final AnimationController controller;

  AnimatedOverlay(Duration duration) : super() {
    controller = AnimationController(
      vsync: this,
      duration: duration,
    );
  }

  Animation<T> createAnimation<T>({
    required T begin,
    required T end,
    Curve curve = Curves.easeInOutCubic,
  }) {
    controller.reset();
    if (begin == end) {
      return AlwaysStoppedAnimation<T>(end);
    } else {
      return Tween<T>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: controller,
          curve: curve,
        ),
      );
    }
  }
}

class CustomAlign extends AnimatedWidget {
  final Widget child;
  final Animation<Alignment> animation;

  const CustomAlign({
    super.key,
    required this.child,
    required this.animation,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: animation.value,
      child: child,
    );
  }
}
