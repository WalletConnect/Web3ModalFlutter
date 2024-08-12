import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/constants/url_constants.dart';
import 'package:web3modal_flutter/services/blockchain_service/models/blockchain_identity.dart';
import 'package:web3modal_flutter/services/blockchain_service/i_blockchain_service.dart';
import 'package:web3modal_flutter/services/logger_service/logger_service_singleton.dart';

class BlockChainService implements IBlockChainService {
  late final ICore _core;
  late final String _baseUrl;
  String? _clientId;

  BlockChainService({required ICore core})
      : _core = core,
        _baseUrl = '${UrlConstants.blockChainService}/v1';

  Map<String, String?> get _requiredParams => {
        'projectId': _core.projectId,
        'clientId': _clientId,
      };

  Map<String, String> get _requiredHeaders => {
        'x-sdk-type': StringConstants.X_SDK_TYPE,
        'x-sdk-version': 'flutter-${StringConstants.X_SDK_VERSION}',
      };

  @override
  Future<void> init() async {
    _clientId = await _core.crypto.getClientId();
  }

  @override
  Future<BlockchainIdentity> getIdentity(String address) async {
    try {
      final uri = Uri.parse('$_baseUrl/identity/$address');
      final queryParams = {..._requiredParams};
      if (queryParams['clientId'] == null) {
        queryParams['clientId'] = await _core.crypto.getClientId();
      }
      final response = await http.get(
        uri.replace(queryParameters: queryParams),
        headers: _requiredHeaders,
      );
      if (response.statusCode == 200) {
        return BlockchainIdentity.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load avatar');
      }
    } catch (e) {
      loggerService.instance.e('[$runtimeType] getIdentity: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getRpcRequest({
    required String method,
    required List<dynamic> params,
    required String chain,
  }) async {
    final bool isChainId = NamespaceUtils.isValidChainId(chain);
    if (!isChainId) {
      throw Errors.getSdkError(
        Errors.UNSUPPORTED_CHAINS,
        context: '[$runtimeType] chain should be CAIP-2 valid',
      );
    }
    final uri = Uri.parse(_baseUrl);
    final queryParams = {..._requiredParams, 'chainId': chain};
    if (queryParams['clientId'] == null) {
      queryParams['clientId'] = await _core.crypto.getClientId();
    }
    final response = await http.post(
      uri.replace(queryParameters: queryParams),
      headers: {
        ..._requiredHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': method,
        'params': params,
        'chainId': chain.split(':').last,
      }),
    );
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        final result = _parseRpcResultAs<String>(response.body);
        final amount = EtherAmount.fromBigInt(EtherUnit.wei, hexToInt(result));
        return amount.getValueInUnit(EtherUnit.ether);
      } catch (e) {
        rethrow;
      }
    } else {
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final reasons = result['reasons'] as List;
      final reason = reasons.first as Map<String, dynamic>;
      loggerService.instance.i(
        '[$runtimeType] Failed to get request $method. ${reason['description']}',
      );
    }
  }

  T _parseRpcResultAs<T>(String body) {
    final result = Map<String, dynamic>.from({
      ...jsonDecode(body),
      'id': -1,
    });
    final jsonResponse = JsonRpcResponse.fromJson(result);
    if (jsonResponse.result != null) {
      return jsonResponse.result;
    }
    throw jsonResponse.error!;
  }

  // @override
  // Future<double?> getBalance(
  //   String address,
  //   String currency, {
  //   String? chain,
  //   String? forceUpdate,
  // }) async {
  //   final uri = Uri.parse('$_baseUrl/account/$address/balance');
  //   final queryParams = {
  //     ..._requiredParams,
  //     'currency': currency,
  //     if (chain != null) 'chainId': chain,
  //     if (forceUpdate != null) 'forceUpdate': forceUpdate,
  //   };
  //   final response = await http.get(
  //     uri.replace(queryParameters: queryParams),
  //     headers: {
  //       ..._requiredHeaders,
  //       // 'chain': chainId,
  //       // 'forceUpdate': string
  //       // 'Content-Type': 'application/json',
  //     },
  //     // body: jsonEncode({
  //     //   'jsonrpc': '2.0',
  //     //   'method': 'eth_getBalance',
  //     //   'params': [address, 'latest'],
  //     //   'chainId': 1
  //     // }),
  //   );
  //   _core.logger.i('[$runtimeType] getBalance $address: ${response.body}');
  //   if (response.statusCode == 200) {
  //   } else {
  //     throw Exception('Failed to load balance');
  //   }
  // }

  // @override
  // Future<String> fetchEnsName(String rpcUrl, String address) async {
  //   return '';
  // }

  // @override
  // Future<String> fetchEnsAvatar(String rpcUrl, String address) async {
  //   return '';
  // }
}
