import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/toast/toast_message.dart';
import 'package:web3modal_flutter/services/toast/toast_service.dart';
import 'package:web3modal_flutter/widgets/toast/web3modal_toast.dart';

class Web3ModalToastManager extends StatelessWidget {
  const Web3ModalToastManager({
    super.key,
    required this.toastService,
  });

  final ToastService toastService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ToastMessage?>(
      stream: toastService.toasts,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Web3ModalToast(message: snapshot.data!);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
