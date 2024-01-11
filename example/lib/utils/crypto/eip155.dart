import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_flutter_dapp/models/eth/ethereum_transaction.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/contract.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/test_data.dart';

enum EIP155UIMethods {
  personalSign,
  ethSignTypedDataV4,
  ethSendTransaction,
  requestAccounts,
  ethSignTypedDataV3,
  ethSignTransaction,
  walletWatchAsset;

  String get name {
    switch (this) {
      case personalSign:
        return 'personal_sign';
      case ethSignTypedDataV4:
        return 'eth_signTypedData_v4';
      case ethSendTransaction:
        return 'eth_sendTransaction';
      case requestAccounts:
        return 'eth_requestAccounts';
      case ethSignTypedDataV3:
        return 'eth_signTypedData_v3';
      case ethSignTransaction:
        return 'eth_signTransaction';
      case walletWatchAsset:
        return 'wallet_watchAsset';
    }
  }
}

class EIP155 {
  static EIP155UIMethods methodFromName(String name) {
    switch (name) {
      case 'personal_sign':
        return EIP155UIMethods.personalSign;
      case 'eth_signTypedData_v4':
        return EIP155UIMethods.ethSignTypedDataV4;
      case 'eth_sendTransaction':
        return EIP155UIMethods.ethSendTransaction;
      case 'eth_requestAccounts':
        return EIP155UIMethods.requestAccounts;
      case 'eth_signTypedData_v3':
        return EIP155UIMethods.ethSignTypedDataV3;
      case 'eth_signTransaction':
        return EIP155UIMethods.ethSignTransaction;
      case 'wallet_watchAsset':
        return EIP155UIMethods.walletWatchAsset;
      default:
        throw Exception('Unrecognized method');
    }
  }

  static Future<dynamic> callMethod({
    required W3MService w3mService,
    required String topic,
    required EIP155UIMethods method,
    required String chainId,
    required String address,
  }) {
    final cid = int.parse(chainId.split(':')[1]);
    switch (method) {
      case EIP155UIMethods.requestAccounts:
        return w3mService.request(
          topic: topic,
          chainId: chainId,
          request: SessionRequestParams(
            method: method.name,
            params: [],
          ),
        );
      case EIP155UIMethods.ethSignTypedDataV3:
        return w3mService.request(
          topic: topic,
          chainId: chainId,
          request: SessionRequestParams(
            method: method.name,
            params: [address, typeDataV3(cid)],
          ),
        );
      case EIP155UIMethods.personalSign:
        return personalSign(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          address: address,
          data: testSignData,
        );
      case EIP155UIMethods.ethSignTypedDataV4:
        return ethSignTypedDataV4(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          address: address,
          data: typeDataV4(cid),
        );
      case EIP155UIMethods.ethSignTransaction:
      case EIP155UIMethods.ethSendTransaction:
        return ethSendTransaction(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          method: method.name,
          transaction: EthereumTransaction(
            from: address,
            to: address,
            value: '0x01',
            data: '0x', // to make it work with some wallets
          ),
        );
      case EIP155UIMethods.walletWatchAsset:
        return walletWatchAsset(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          method: method.name,
        );
    }
  }

  static Future<dynamic> personalSign({
    required W3MService w3mService,
    required String topic,
    required String chainId,
    required String address,
    required String data,
  }) async {
    return await w3mService.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: EIP155UIMethods.personalSign.name,
        params: [address, data],
      ),
    );
  }

  static Future<dynamic> ethSignTypedDataV4({
    required W3MService w3mService,
    required String topic,
    required String chainId,
    required String address,
    required String data,
  }) async {
    return await w3mService.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: EIP155UIMethods.ethSignTypedDataV4.name,
        params: [address, data],
      ),
    );
  }

  static Future<dynamic> ethSendTransaction({
    required W3MService w3mService,
    required String topic,
    required String chainId,
    required EthereumTransaction transaction,
    required String method,
  }) async {
    return await w3mService.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: EIP155UIMethods.ethSendTransaction.name,
        params: [transaction.toJson()],
      ),
    );
  }

  static Future<dynamic> walletWatchAsset({
    required W3MService w3mService,
    required String topic,
    required String chainId,
    required String method,
  }) async {
    return await w3mService.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: method,
        params: {
          "type": "ERC20",
          "options": {
            "address": "0xcf664087a5bb0237a0bad6742852ec6c8d69a27a",
            "symbol": "WONE",
            "decimals": 18,
            "image":
                "https://s2.coinmarketcap.com/static/img/coins/64x64/11696.png"
          }
        },
      ),
    );
  }

  static Future<dynamic> testContractCall({
    required W3MService w3mService,
  }) async {
    // Create a Web3Client by passing a chain rpcUrl and an http client
    final ethChain = W3MChainPresets.chains['1']!;
    final ethClient = Web3Client(ethChain.rpcUrl, http.Client());

    // Create DeployedContract object using contract's ABI and address
    final deployedContract = DeployedContract(
      ContractAbi.fromJson(
        jsonEncode(ContractDetails.readContractAbi),
        'TetherToken',
      ),
      EthereumAddress.fromHex(ContractDetails.contractAddress),
    );

    // Query contract's functions
    final nameFunction = deployedContract.function('name');
    final totalSupplyFunction = deployedContract.function('totalSupply');
    final balanceFunction = deployedContract.function('balanceOf');

    final nameResult = await ethClient.call(
      contract: deployedContract,
      function: nameFunction,
      params: [],
    );

    final totalSupply = await ethClient.call(
      contract: deployedContract,
      function: totalSupplyFunction,
      params: [],
    );

    final balanceOf = await ethClient.call(
      contract: deployedContract,
      function: balanceFunction,
      params: [
        EthereumAddress.fromHex(w3mService.session!.address!),
      ],
    );

    return {
      'name': '${nameResult.first}',
      'totalSupply': '${totalSupply.first}',
      'balance': '${balanceOf.first}',
    };
  }
}
