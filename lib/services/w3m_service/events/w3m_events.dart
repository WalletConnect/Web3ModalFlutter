import 'package:web3modal_flutter/web3modal_flutter.dart';

class ModalConnect extends EventArgs {
  final W3MSession session;
  ModalConnect(this.session);

  @override
  String toString() {
    return 'ModalConnect(session: ${session.toJson()})';
  }
}

class ModalNetworkChange extends EventArgs {
  final String? previous;
  final String current;
  ModalNetworkChange({
    required this.previous,
    required this.current,
  });

  @override
  String toString() {
    return 'ModalNetworkChange(previous: $previous, current: $current)';
  }
}

class ModalDisconnect extends EventArgs {
  final String? topic;
  final int? id;
  ModalDisconnect({this.topic, this.id});

  @override
  String toString() {
    return 'ModalDisconnect(topic: $topic, id: $id)';
  }
}

class ModalError extends EventArgs {
  final String message;
  ModalError(this.message);

  @override
  String toString() {
    return 'ModalError(message: $message)';
  }
}

class WalletNotInstalled extends ModalError {
  WalletNotInstalled() : super('Wallet app not installed');
}

class ErrorOpeningWallet extends ModalError {
  ErrorOpeningWallet() : super('Unable to open Wallet app');
}

class UserRejectedConnection extends ModalError {
  UserRejectedConnection() : super('User rejected Wallet connection');
}
