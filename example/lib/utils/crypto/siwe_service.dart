import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:walletconnect_flutter_dapp/utils/dart_defines.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';

class SIWESampleWebService {
  late Map<String, String> _headers;

  SIWESampleWebService() {
    _headers = coreUtils.instance.getAPIHeaders(
      DartDefines.appKitProjectId,
    );
  }

  Future<Map<String, dynamic>> getNonce() async {
    try {
      final res = await http.get(
        Uri.parse('${DartDefines.authApiUrl}/auth/v1/nonce'),
        headers: _headers,
      );
      final nonceRes = json.decode(res.body) as Map<String, dynamic>;
      final newToken = nonceRes['token'] as String;
      _headers['Authorization'] = 'Bearer $newToken';
      // Persist the newToken so it can be used again with getSession() even if the user terminated the app
      return nonceRes;
    } catch (error) {
      debugPrint('[SIWESERVICE] ⛔️ getNonce() => ${error.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAppKitAuthSession() async {
    try {
      final response = await http.get(
        Uri.parse('${DartDefines.authApiUrl}/auth/v1/me'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception(response.statusCode.toString());
    } catch (error) {
      debugPrint(
          '[SIWESERVICE] ⛔️ getAppKitAuthSession() => ${error.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> authenticate(
    Map<String, dynamic> payload, {
    required String domain,
  }) async {
    try {
      final uri = Uri.parse('${DartDefines.authApiUrl}/auth/v1/authenticate');
      final res = await http.post(
        uri.replace(queryParameters: {'domain': domain}),
        headers: {
          ..._headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      debugPrint(jsonEncode(payload));
      debugPrint(res.request?.url.toString());
      debugPrint(jsonEncode(res.request?.headers));
      debugPrint(res.body);
      final authenticateRes = jsonDecode(res.body);
      final newToken = authenticateRes['token'] as String;
      _headers['Authorization'] = 'Bearer $newToken';
      // Persist the newToken so it can be used again with getSession() even if the user terminated the app
      return authenticateRes;
    } catch (error) {
      debugPrint('[SIWESERVICE] ⛔️ authenticate() => ${error.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('${DartDefines.authApiUrl}/auth/v1/update-user'),
        headers: _headers,
        body: json.encode({'metadata': data}),
      );
      final updateUserRes = json.decode(res.body);
      return updateUserRes;
    } catch (error) {
      debugPrint('[SIWESERVICE] ⛔️ updateUser() => ${error.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> appKitAuthSignOut() async {
    try {
      final res = await http.post(
        Uri.parse('${DartDefines.authApiUrl}/auth/v1/sign-out'),
        headers: _headers,
      );
      final signOutRes = json.decode(res.body) as Map<String, dynamic>;
      return signOutRes;
    } catch (error) {
      debugPrint('[SIWESERVICE] ⛔️ appKitAuthSignOut() => ${error.toString()}');
      rethrow;
    }
  }
}
