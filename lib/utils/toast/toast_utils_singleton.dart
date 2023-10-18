import 'package:web3modal_flutter/utils/toast/i_toast_utils.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils.dart';

class ToastUtilsSingleton {
  IToastUtils instance;

  ToastUtilsSingleton() : instance = ToastUtils();
}

final toastUtils = ToastUtilsSingleton();
