import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/blockchain_service/models/blockchain_identity.dart';
import 'package:web3modal_flutter/services/blockchain_service/i_blockchain_service.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';

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
    final url = await coreUtils.instance.getBlockchainApiUrl();
    final scope = '${StringConstants.namespace}:$chainId';
    final clientId = await _web3app.core.crypto.getClientId();
    final uri = Uri.parse('$url/v1/identity/$address');
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
}
