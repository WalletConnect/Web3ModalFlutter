import 'dart:async';

import 'package:web3modal_flutter/utils/toast/toast_message.dart';

class ToastMessageCompleter {
  final ToastMessage message;
  final Completer completer = Completer();

  ToastMessageCompleter(this.message);
}

abstract class IToastUtils {
  Stream<ToastMessage?> get toasts;

  void show(ToastMessage message);

  void clear();
}
