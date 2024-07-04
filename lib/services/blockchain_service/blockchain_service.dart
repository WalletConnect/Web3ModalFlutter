import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/constants/url_constants.dart';
import 'package:web3modal_flutter/services/blockchain_service/models/blockchain_identity.dart';
import 'package:web3modal_flutter/services/blockchain_service/i_blockchain_service.dart';

class BlockChainService extends IBlockChainService {
  //
  @override
  final String projectId;

  final IWeb3App _web3app;

  BlockChainService({
    required this.projectId,
    required IWeb3App web3app,
  }) : _web3app = web3app;

  @override
  Future<BlockchainIdentity> getIdentity(String address, int chainId) async {
    final scope = '${StringConstants.namespace}:$chainId';
    final clientId = await _web3app.core.crypto.getClientId();
    final uri = Uri.parse(
      '${UrlConstants.blockChainService}/v1/identity/$address',
    );
    final queryParams = {
      'chainId': scope,
      'projectId': projectId,
      'clientId': clientId,
    };
    final response = await http.get(uri.replace(queryParameters: queryParams));
    if (response.statusCode == 200) {
      return BlockchainIdentity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load avatar');
    }
  }

  // TODO to be implemented
  // @override
  // Future<JsonRpcResponse?> getBalance(String chainId, String address) async {
  //   // final client = Web3Client(rpcUrl, Client());
  //   // final amount = await client.getBalance(EthereumAddress.fromHex(address));
  //   // return amount.getValueInUnit(EtherUnit.ether);
  //   final scope = '${StringConstants.namespace}:$chainId';
  //   final clientId = await _web3app.core.crypto.getClientId();
  //   final uri = Uri.parse('${UrlConstants.blockChainService}/v1');
  //   final queryParams = {
  //     'chainId': scope,
  //     'projectId': projectId,
  //     'clientId': clientId,
  //   };
  //   // "chainId=eip155%3A1&projectId=cad4956f31a5e40a00b62865b030c6f8&clientId=did%3Akey%3Az6MkgNA9sezpYrpiJGSkkQwUQSqoEWSDsDFZifbu6tYbu…"
  //   final response = await http.post(
  //     uri.replace(queryParameters: queryParams),
  //     headers: {
  //       ...coreUtils.instance.getAPIHeaders(projectId),
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       'jsonrpc': '2.0',
  //       'method': 'eth_getBalance',
  //       'params': [address, 'latest'],
  //       'chainId': 1
  //     }),
  //   );
  //   print(response.body);
  //   if (response.statusCode == 200) {
  //     final result = JsonRpcResponse.fromJson(jsonDecode(response.body));
  //     final bytes = hex.decode(result.result.toString().replaceFirst('0x', ''));
  //     // "{"jsonrpc":"2.0","id":"","result":"0x0"}"
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
