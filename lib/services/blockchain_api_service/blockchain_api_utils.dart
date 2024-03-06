import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_identity.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/i_blockchain_api_utils.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';

class BlockchainApiUtils extends IBlockchainApiUtils {
  //
  @override
  final String projectId;

  BlockchainApiUtils({required this.projectId});

  @override
  Future<BlockchainIdentity> getIdentity(String address, int chainId) async {
    final scope = '${StringConstants.namespace}:$chainId';
    final url = await coreUtils.instance.getBlockchainApiUrl();
    final endpoint =
        '$url/v1/identity/$address?chainId=$scope&projectId=$projectId';
    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      return BlockchainIdentity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load avatar');
    }
  }
}
