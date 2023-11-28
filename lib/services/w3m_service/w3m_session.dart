import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_session.dart';

class W3MSession {
  SessionData? sessionData;
  MagicSession? magicSession;

  W3MSession({this.sessionData, this.magicSession});
}
