import 'package:w_common/disposable.dart';
import 'dart:async';

import 'package:web3modal_flutter/utils/toast/toast_message.dart';
import 'package:web3modal_flutter/utils/toast/i_toast_utils.dart';

class ToastUtils extends IToastUtils with Disposable {
  final _toastController = StreamController<ToastMessage?>.broadcast();

  // final _queue = Queue<ToastMessage>();

  // bool _isShowing = false;

  @override
  Stream<ToastMessage?> get toasts => _toastController.stream;

  @override
  Future<void> show(ToastMessage? message) async {
    _toastController.add(message);

    // _queue.add(message);

    // if (!_isShowing) {
    //   _popToast();
    // }

    // await message.completer.future;
  }

  @override
  void clear() {
    // _queue.clear();
    _toastController.add(null);
  }

  // Future<void> _popToast() async {
  //   if (_queue.isNotEmpty) {
  //     _isShowing = true;
  //     final ToastMessage message = _queue.removeFirst();
  //     _toastController.add(message);
  //     await message.completer.future;
  //     _isShowing = false;
  //     _popToast();
  //   } else {
  //     _isShowing = false;
  //     _toastController.add(null);
  //   }
  // }

  // @override
  // // ignore: prefer_void_to_null
  // Future<Null> onDispose() async {
  //   _toastController.close();
  // }
}
