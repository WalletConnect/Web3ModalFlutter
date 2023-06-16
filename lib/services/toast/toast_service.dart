import 'dart:collection';
import 'package:web3modal_flutter/services/toast/toast_message.dart';
import 'dart:async';

class ToastService {
  final _toastController = StreamController<ToastMessage?>.broadcast();

  Stream<ToastMessage?> get toasts => _toastController.stream;

  final _queue = Queue<ToastMessage>();

  bool _isShowing = false;

  void show(ToastMessage message) {
    _queue.add(message);

    if (!_isShowing) {
      _popToast();
    }
  }

  void _popToast() {
    if (_queue.isNotEmpty) {
      _isShowing = true;
      final message = _queue.removeFirst();
      _toastController.add(message);
      Future.delayed(message.duration).then((_) {
        _isShowing = false;
        _popToast();
      });
    } else {
      _isShowing = false;
      _toastController.add(null);
    }
  }

  void dispose() {
    _toastController.close();
  }
}
