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

  bool get loaded => type == '@w3m-app/FRAME_LOADED';
  bool get initialized => type == '@w3m-app/INITIALIZED';
  bool get connected => type == '@w3m-frame/IS_CONNECTED_SUCCESS';
  bool get error => type == '@w3m-frame/IS_CONNECTED_ERROR';
  bool get otp => type == '@w3m-frame/CONNECT_OTP_SUCCESS';
  bool get userData => type == '@w3m-frame/GET_USER_SUCCESS';
}
