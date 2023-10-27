import 'dart:async';

import 'package:web3modal_flutter/utils/toast/toast_message.dart';
import 'package:web3modal_flutter/utils/toast/i_toast_utils.dart';

class ToastUtils extends IToastUtils {
  final _toastController = StreamController<ToastMessage?>.broadcast();

  @override
  Stream<ToastMessage?> get toasts => _toastController.stream;

  @override
  void show(ToastMessage? message) {
    _toastController.add(message);
  }

  @override
  void clear() {
    _toastController.add(null);
  }
}
