import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:convert/convert.dart';

class MagicMessage {
  String type;
  dynamic payload;

  MagicMessage({
    required this.type,
    this.payload,
  });

  factory MagicMessage.fromJson(Map<String, dynamic> json) {
    return MagicMessage(
      type: json['type'],
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {'type': type};
    if ((payload ?? '').isNotEmpty) {
      params['payload'] = payload;
    }

    return params;
  }

  // @w3m-frame events
  bool get syncThemeSuccess => type == '@w3m-frame/SYNC_THEME_SUCCESS';
  bool get syncDataSuccess => type == '@w3m-frame/SYNC_DAPP_DATA_SUCCESS';
  bool get connectEmailSuccess => type == '@w3m-frame/CONNECT_EMAIL_SUCCESS';
  bool get connectEmailError => type == '@w3m-frame/CONNECT_EMAIL_ERROR';
  bool get isConnectSuccess => type == '@w3m-frame/IS_CONNECTED_SUCCESS';
  bool get isConnectError => type == '@w3m-frame/IS_CONNECTED_ERROR';
  bool get connectOtpSuccess => type == '@w3m-frame/CONNECT_OTP_SUCCESS';
  bool get connectOtpError => type == '@w3m-frame/CONNECT_OTP_ERROR';
  bool get getUserSuccess => type == '@w3m-frame/GET_USER_SUCCESS';
  bool get getUserError => type == '@w3m-frame/GET_USER_ERROR';
  bool get sessionUpdate => type == '@w3m-frame/SESSION_UPDATE';
  bool get switchNetworkSuccess => type == '@w3m-frame/SWITCH_NETWORK_SUCCESS';
  bool get switchNetworkError => type == '@w3m-frame/SWITCH_NETWORK_ERROR';
  bool get rpcRequestSuccess => type == '@w3m-frame/RPC_REQUEST_SUCCESS';
  bool get rpcRequestError => type == '@w3m-frame/RPC_REQUEST_ERROR';
  bool get signOutSuccess => type == '@w3m-frame/SIGN_OUT_SUCCESS';
  bool get signOutError => type == '@w3m-frame/SIGN_OUT_ERROR';
}

// @w3m-app events
class IsConnected extends MagicMessage {
  IsConnected() : super(type: '@w3m-app/IS_CONNECTED');

  @override
  String toString() => '{type: "${super.type}"}';
}

class SwitchNetwork extends MagicMessage {
  final String chainId;
  SwitchNetwork({
    required this.chainId,
  }) : super(type: '@w3m-app/SWITCH_NETWORK');

  @override
  String toString() => '{type:\'${super.type}\',payload:{chainId:$chainId}}';
}

class ConnectEmail extends MagicMessage {
  final String email;
  ConnectEmail({required this.email}) : super(type: '@w3m-app/CONNECT_EMAIL');

  @override
  String toString() => '{type:\'${super.type}\',payload:{email:\'$email\'}}';
}

class ConnectDevice extends MagicMessage {
  ConnectDevice() : super(type: '@w3m-app/CONNECT_DEVICE');

  @override
  String toString() => '{type: "${super.type}"}';
}

class ConnectOtp extends MagicMessage {
  final String otp;
  ConnectOtp({required this.otp}) : super(type: '@w3m-app/CONNECT_OTP');

  @override
  String toString() => '{type:\'${super.type}\',payload:{otp:\'$otp\'}}';
}

class GetUser extends MagicMessage {
  final String? chainId;
  GetUser({this.chainId}) : super(type: '@w3m-app/GET_USER');

  @override
  String toString() {
    if ((chainId ?? '').isNotEmpty) {
      return '{type:\'${super.type}\',payload:{chainId:$chainId}}';
    }
    return '{type:\'${super.type}\'}';
  }
}

class SignOut extends MagicMessage {
  SignOut() : super(type: '@w3m-app/SIGN_OUT');

  @override
  String toString() => '{type: "${super.type}"}';
}

class GetChainId extends MagicMessage {
  GetChainId() : super(type: '@w3m-app/GET_CHAIN_ID');

  @override
  String toString() => '{type: "${super.type}"}';
}

class RpcRequest extends MagicMessage {
  final String method;
  final List<dynamic> params;

  RpcRequest({
    required this.method,
    required this.params,
  }) : super(type: '@w3m-app/RPC_REQUEST');

  @override
  String toString() {
    debugPrint('[$runtimeType] method $method');
    final m = 'method:\'$method\'';
    final t = 'type:\'${super.type}\'';
    final p = params.map((i) => '$i').toList();

    if (method == 'personal_sign') {
      final bytes = utf8.encode(p.first);
      final data = hex.encode(bytes);
      final address = p.last;
      return '{$t,payload:{$m,params:[\'0x$data\',\'$address\']}}';
    }
    if (method == 'eth_signTypedData_v4' ||
        method == 'eth_signTypedData_v3' ||
        method == 'eth_signTypedData') {
      // final data = jsonEncode(jsonDecode(p.first) as Map<String, dynamic>);
      final data = p.first;
      final address = p.last;
      return '{$t,payload:{$m,params:[\'$address\',\'$data\']}}';
    }
    if (method == 'eth_sendTransaction' || method == 'eth_signTransaction') {
      final jp = jsonEncode(params.first);
      return '{$t,payload:{$m,params:[$jp]}}';
    }

    final ps = p.join(',');
    return '{$t,payload:{$m,params:[$ps]}}';
  }
}

class UpdateEmail extends MagicMessage {
  UpdateEmail() : super(type: '@w3m-app/UPDATE_EMAIL');

  @override
  String toString() => '{type: "${super.type}"}';
}
// readonly APP_AWAIT_UPDATE_EMAIL: "@w3m-app/AWAIT_UPDATE_EMAIL";

class SyncTheme extends MagicMessage {
  final Web3ModalTheme? theme;
  SyncTheme({required this.theme}) : super(type: '@w3m-app/SYNC_THEME');

  @override
  String toString() {
    final mode = theme?.isDarkMode == true ? 'dark' : 'light';
    final tm = 'themeMode:\'$mode\'';
    final themeData = theme?.themeData ?? Web3ModalThemeData();
    late Web3ModalColors colors;
    if (mode == 'dark') {
      colors = themeData.darkColors;
    } else {
      colors = themeData.lightColors;
    }

    // Available keys:
    // '--w3m-accent'?: string
    // '--w3m-color-mix'?: string
    // '--w3m-color-mix-strength'?: number
    // '--w3m-font-family'?: string
    // '--w3m-font-size-master'?: string
    // '--w3m-border-radius-master'?: string
    // '--w3m-z-index'?: number

    final c1 = '\'--w3m-accent\':\'${Util.colorToRGBA(colors.accent100)}\'';
    // final c2 = '\'--w3m-color-mix\':\'${Util.colorToRGBA(colors.background125)}\'';
    // final c3 = '\'--w3m-color-mix-strength\':100';
    // final c4 = '\'--w3m-z-index\':100000000';
    final tv = 'themeVariables:{$c1}';

    return '{type:\'${super.type}\',payload:{$tm,$tv}}';
  }
}

class SyncAppData extends MagicMessage {
  SyncAppData({
    required this.metadata,
    required this.sdkVersion,
    required this.projectId,
  }) : super(type: '@w3m-app/SYNC_DAPP_DATA');

  final PairingMetadata metadata;
  final String sdkVersion;
  final String projectId;

  @override
  String toString() {
    final v = 'verified: true';
    final p1 = 'projectId:\'$projectId\'';
    final p2 = 'sdkVersion:\'$sdkVersion\'';
    final m1 = 'name:\'${metadata.name}\'';
    final m2 = 'description:\'${metadata.description}\'';
    final m3 = 'url:\'${metadata.url}\'';
    final m4 = 'icons:["${metadata.icons.first}"]';
    final p3 = 'metadata:{$m1,$m2,$m3,$m4}';
    final p = 'payload:{$v,$p1,$p2,$p3}';
    return '{type:\'${super.type}\',$p}';
  }
}
