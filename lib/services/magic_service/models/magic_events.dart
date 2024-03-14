import 'package:web3modal_flutter/services/magic_service/models/magic_data.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class MagicConnectEvent implements EventArgs {
  final MagicData? data;
  MagicConnectEvent(this.data);

  @override
  String toString() => data?.toString() ?? '';
}

class MagicSessionEvent implements EventArgs {
  String? email;
  String? address;
  int? chainId;

  MagicSessionEvent({
    this.email,
    this.address,
    this.chainId,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {};
    if ((email ?? '').isNotEmpty) {
      params['email'] = email;
    }
    if ((address ?? '').isNotEmpty) {
      params['address'] = address;
    }
    if (chainId != null) {
      params['chainId'] = chainId;
    }

    return params;
  }

  @override
  String toString() => toJson().toString();
}

class MagicRequestEvent implements EventArgs {
  dynamic request;
  dynamic result;
  bool? success;

  MagicRequestEvent({
    required this.request,
    this.result,
    this.success,
  });
}

class MagicErrorEvent implements EventArgs {
  final String? error;
  MagicErrorEvent(this.error);
}

class IsConnectedErrorEvent extends MagicErrorEvent {
  IsConnectedErrorEvent() : super('Error checking connection');
}

class ConnectEmailErrorEvent extends MagicErrorEvent {
  ConnectEmailErrorEvent() : super('Error connecting email');
}

class ConnectOtpErrorEvent extends MagicErrorEvent {
  ConnectOtpErrorEvent() : super('Error validating OTP code');
}

class GetUserErrorEvent extends MagicErrorEvent {
  GetUserErrorEvent() : super('Error getting user');
}

class SwitchNetworkErrorEvent extends MagicErrorEvent {
  SwitchNetworkErrorEvent() : super('Error switching network');
}

class SignOutErrorEvent extends MagicErrorEvent {
  SignOutErrorEvent() : super('Error on Signing out');
}

class RpcRequestErrorEvent extends MagicErrorEvent {
  RpcRequestErrorEvent(String? message)
      : super(message ?? 'Error during request');
}
