import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';

class Web3ModalProvider extends InheritedWidget {
  final IW3MService service;

  const Web3ModalProvider({
    super.key,
    required this.service,
    required super.child,
  });

  static Web3ModalProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Web3ModalProvider>();
  }

  static Web3ModalProvider of(BuildContext context) {
    final Web3ModalProvider? result = maybeOf(context);
    assert(result != null, 'No Web3ModalProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Web3ModalProvider oldWidget) {
    return true;
  }
}
