import 'package:web3modal_flutter/services/magic_service/models/magic_user_data.dart';

class MagicSession {
  final String pk;
  final String jwt;
  final String rt;
  final MagicUserData userData;

  const MagicSession({
    required this.pk,
    required this.jwt,
    required this.rt,
    required this.userData,
  });

  factory MagicSession.fromJson(Map<String, dynamic> json) {
    return MagicSession(
      pk: json['pk'],
      rt: json['rt'],
      jwt: json['jwt'],
      userData: MagicUserData.fromJson(json['userData']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pk': pk,
      'rt': rt,
      'jwt': jwt,
      'userData': userData.toJson(),
    };
  }
}
