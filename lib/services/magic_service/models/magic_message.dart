class MagicMessage {
  String type;
  Map<String, dynamic>? payload;
  String? rt;
  String? jwt;
  String? action;

  MagicMessage({
    required this.type,
    this.payload,
    this.rt,
    this.jwt,
    this.action,
  });

  factory MagicMessage.fromJson(Map<String, dynamic> json) {
    return MagicMessage(
      type: json['type'],
      rt: json['rt'],
      jwt: json['jwt'],
      action: json['action'],
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {'type': type};
    if ((payload ?? {}).isNotEmpty) {
      params['payload'] = payload;
    }
    if ((rt ?? '').isNotEmpty) {
      params['rt'] = rt;
    }
    if ((jwt ?? '').isNotEmpty) {
      params['jwt'] = jwt;
    }
    if ((action ?? '').isNotEmpty) {
      params['action'] = action;
    }

    return params;
  }

  bool get frameLoaded => type == '@w3m-app/FRAME_LOADED';

  // @w3m-app events
  bool get connectEmail => type == '@w3m-app/CONNECT_EMAIL';
  bool get connectOtp => type == '@w3m-app/CONNECT_OTP';
  bool get getUser => type == '@w3m-app/GET_USER';
  bool get switchNetwork => type == '@w3m-app/SWITCH_NETWORK';
  bool get rpcRequest => type == '@w3m-app/RPC_REQUEST';

  // @w3m-frame events
  bool get emailSuccess => type == '@w3m-frame/CONNECT_EMAIL_SUCCESS';
  bool get connectSuccess => type == '@w3m-frame/IS_CONNECTED_SUCCESS';
  bool get connectError => type == '@w3m-frame/IS_CONNECTED_ERROR';
  bool get otpSuccess => type == '@w3m-frame/CONNECT_OTP_SUCCESS';
  bool get userSuccess => type == '@w3m-frame/GET_USER_SUCCESS';
  bool get sessionUpdate => type == '@w3m-frame/SESSION_UPDATE';
  bool get networkSuccess => type == '@w3m-frame/SWITCH_NETWORK_SUCCESS';
  // VERIFY_DEVICE
}

class FrameLoaded extends MagicMessage {
  FrameLoaded() : super(type: '@w3m-app/FRAME_LOADED');

  @override
  String toString() => '{type: "${super.type}"}';
}

class FrameError extends MagicMessage {
  FrameError() : super(type: '@w3m-app/ERROR');

  @override
  String toString() => '{type: "${super.type}"}';
}
