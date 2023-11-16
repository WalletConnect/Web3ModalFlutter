import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web3modal_flutter/constants/eth_constants.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_identity.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/i_blockchain_api_utils.dart';

class BlockchainApiUtils extends IBlockchainApiUtils {
  @override
  final String blockchainApiUriRoot;

  @override
  final String projectId;

  BlockchainApiUtils({
    this.blockchainApiUriRoot = 'https://rpc.walletconnect.com',
    required this.projectId,
  });

  @override
  Future<BlockchainIdentity> getIdentity(String address, int chainId) async {
    final scope = '${EthConstants.namespace}:$chainId';
    final endpoint = '$blockchainApiUriRoot/v1/identity/$address'
        '?chainId=$scope&projectId=$projectId';

    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      return BlockchainIdentity.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception('Failed to load data');
    }
  }
}
