import 'dart:collection';
import 'package:web3modal_flutter/services/toast/toast_message.dart';
import 'dart:async';

class ToastMessageCompleter {
  final ToastMessage message;
  final Completer completer = Completer();

  ToastMessageCompleter(this.message);
}

class ToastService {
  final _toastController = StreamController<ToastMessage?>.broadcast();

  Stream<ToastMessage?> get toasts => _toastController.stream;

  final _queue = Queue<ToastMessageCompleter>();

  bool _isShowing = false;

  Future<void> show(ToastMessage message) async {
    final completer = ToastMessageCompleter(message);

    _queue.add(completer);

    if (!_isShowing) {
      _popToast();
    }

    await completer.completer.future;
  }

  Future<void> _popToast() async {
    if (_queue.isNotEmpty) {
      _isShowing = true;
      final messageCompleter = _queue.removeFirst();
      _toastController.add(messageCompleter.message);
      await Future.delayed(messageCompleter.message.duration * 2);
      messageCompleter.completer.complete();
      _isShowing = false;
      _popToast();
    } else {
      _isShowing = false;
      _toastController.add(null);
    }
  }

  void dispose() {
    _toastController.close();
  }
}
