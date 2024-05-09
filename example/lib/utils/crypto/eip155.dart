import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/smart_contracts/usdt_contract.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

// ignore: depend_on_referenced_packages
import 'package:convert/convert.dart';

import 'package:walletconnect_flutter_dapp/utils/crypto/smart_contracts/aave_contract.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/test_data.dart';

enum EIP155UIMethods {
  personalSign,
  ethSendTransaction,
  requestAccounts,
  ethSignTypedData,
  ethSignTypedDataV3,
  ethSignTypedDataV4,
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
      case ethSignTypedData:
        return 'eth_signTypedData';
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
      case 'eth_signTypedData':
        return EIP155UIMethods.ethSignTypedData;
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
      case EIP155UIMethods.personalSign:
        return personalSign(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          address: address,
          message: testSignData,
        );
      case EIP155UIMethods.ethSignTypedDataV3:
        return ethSignTypedDataV3(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          address: address,
          data: jsonEncode(typeDataV3(cid)),
        );
      case EIP155UIMethods.ethSignTypedData:
        return ethSignTypedData(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          address: address,
          data: jsonEncode(typedData()),
        );
      case EIP155UIMethods.ethSignTypedDataV4:
        return ethSignTypedDataV4(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          address: address,
          data: jsonEncode(typeDataV4(cid)),
        );
      case EIP155UIMethods.ethSignTransaction:
      case EIP155UIMethods.ethSendTransaction:
        return ethSendTransaction(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          method: method.name,
          transaction: Transaction(
            from: EthereumAddress.fromHex(address),
            to: EthereumAddress.fromHex(
              '0x59e2f66C0E96803206B6486cDb39029abAE834c0',
            ),
            value: EtherAmount.fromInt(EtherUnit.finney, 11), // == 0.011
            nonce: Random().nextInt(10000),
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
    required String message,
  }) async {
    final bytes = utf8.encode(message);
    final encoded = hex.encode(bytes);

    return await w3mService.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: EIP155UIMethods.personalSign.name,
        params: ['0x$encoded', address],
      ),
    );
  }

  static Future<dynamic> ethSignTypedData({
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
        method: EIP155UIMethods.ethSignTypedData.name,
        params: [data, address],
      ),
    );
  }

  static Future<dynamic> ethSignTypedDataV3({
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
        method: EIP155UIMethods.ethSignTypedDataV3.name,
        params: [data, address],
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
        params: [data, address],
      ),
    );
  }

  static Future<dynamic> ethSendTransaction({
    required W3MService w3mService,
    required String topic,
    required String chainId,
    required String method,
    required Transaction transaction,
  }) async {
    return await w3mService.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: method,
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

  static Future<dynamic> callTestSmartContract({
    required W3MService w3mService,
    required String action,
  }) async {
    // Create DeployedContract object using contract's ABI and address
    final deployedContract = DeployedContract(
      ContractAbi.fromJson(
        jsonEncode(AAVESepoliaContract.contractABI),
        'AAVE Token (Sepolia)',
      ),
      EthereumAddress.fromHex(AAVESepoliaContract.contractAddress),
    );

    switch (action) {
      case 'read':
        return _readSmartContract(
          w3mService: w3mService,
          rpcUrl: w3mService.selectedChain!.rpcUrl,
          contract: deployedContract,
          address: w3mService.session!.address!,
        );
      case 'write':
        final decimals = await w3mService.requestReadContract(
          deployedContract: deployedContract,
          functionName: 'decimals',
          rpcUrl: w3mService.selectedChain!.rpcUrl,
        );
        final d = (decimals.first as BigInt);
        final requestValue = _formatValue(0.12, decimals: d);
        return w3mService.requestWriteContract(
          topic: w3mService.session?.topic ?? '',
          chainId: w3mService.selectedChain!.namespace,
          rpcUrl: w3mService.selectedChain!.rpcUrl,
          deployedContract: deployedContract,
          functionName: 'transfer',
          transaction: Transaction(
            from: EthereumAddress.fromHex(w3mService.session!.address!),
          ),
          parameters: [
            EthereumAddress.fromHex(
              '0x59e2f66C0E96803206B6486cDb39029abAE834c0',
            ),
            requestValue, // == 0.12
          ],
        );
      // payable function with no parameters such as:
      // {
      //   "inputs": [],
      //   "name": "functionName",
      //   "outputs": [],
      //   "stateMutability": "payable",
      //   "type": "function"
      // },
      // return w3mService.requestWriteContract(
      //   topic: w3mService.session?.topic ?? '',
      //   chainId: 'eip155:11155111',
      //   rpcUrl: 'https://ethereum-sepolia.publicnode.com',
      //   deployedContract: deployedContract,
      //   functionName: 'functionName',
      //   transaction: Transaction(
      //     from: EthereumAddress.fromHex(w3mService.session!.address!),
      //     value: EtherAmount.fromInt(EtherUnit.finney, 1),
      //   ),
      //   parameters: [],
      // );
      default:
        return Future.value();
    }
  }

  static Future<dynamic> callUSDTSmartContract({
    required W3MService w3mService,
    required String action,
  }) async {
    // Create DeployedContract object using contract's ABI and address
    final deployedContract = DeployedContract(
      ContractAbi.fromJson(
        jsonEncode(USDTContract.contractABI),
        'Tether USD',
      ),
      EthereumAddress.fromHex(USDTContract.contractAddress),
    );

    switch (action) {
      case 'read':
        return _readSmartContract(
          w3mService: w3mService,
          rpcUrl: w3mService.selectedChain!.rpcUrl,
          contract: deployedContract,
          address: w3mService.session!.address!,
        );
      case 'write':
        final decimals = await w3mService.requestReadContract(
          deployedContract: deployedContract,
          functionName: 'decimals',
          rpcUrl: w3mService.selectedChain!.rpcUrl,
        );
        final d = (decimals.first as BigInt);
        final requestValue = _formatValue(0.23, decimals: d);
        return w3mService.requestWriteContract(
          topic: w3mService.session?.topic ?? '',
          chainId: w3mService.selectedChain!.namespace,
          rpcUrl: w3mService.selectedChain!.rpcUrl,
          deployedContract: deployedContract,
          functionName: 'transfer',
          transaction: Transaction(
            from: EthereumAddress.fromHex(w3mService.session!.address!),
          ),
          parameters: [
            EthereumAddress.fromHex(
              '0x59e2f66C0E96803206B6486cDb39029abAE834c0',
            ),
            requestValue, // == 0.23
          ],
        );
      default:
        return Future.value();
    }
  }

  static Future<dynamic> _readSmartContract({
    required W3MService w3mService,
    required String rpcUrl,
    required String address,
    required DeployedContract contract,
  }) async {
    final results = await Future.wait([
      // results[0]
      w3mService.requestReadContract(
        deployedContract: contract,
        functionName: 'name',
        rpcUrl: rpcUrl,
      ),
      // results[1]
      w3mService.requestReadContract(
        deployedContract: contract,
        functionName: 'totalSupply',
        rpcUrl: rpcUrl,
      ),
      // results[2]
      w3mService.requestReadContract(
        deployedContract: contract,
        functionName: 'balanceOf',
        rpcUrl: rpcUrl,
        parameters: [
          EthereumAddress.fromHex(address),
        ],
      ),
      // results[4]
      w3mService.requestReadContract(
        deployedContract: contract,
        functionName: 'decimals',
        rpcUrl: rpcUrl,
      ),
    ]);

    //
    final name = (results[0].first as String);
    final multiplier = _multiplier(results[3].first);
    final total = (results[1].first as BigInt) / BigInt.from(multiplier);
    final balance = (results[2].first as BigInt) / BigInt.from(multiplier);
    final formatter = NumberFormat("#,##0.00000", "en_US");

    return {
      'name': name,
      'totalSupply': formatter.format(total),
      'balance': formatter.format(balance),
    };
  }

  static BigInt _formatValue(num value, {required BigInt decimals}) {
    final multiplier = _multiplier(decimals);
    final result = EtherAmount.fromInt(
      EtherUnit.ether,
      (value * multiplier).toInt(),
    );
    return result.getInEther;
  }

  static int _multiplier(BigInt decimals) {
    final d = decimals.toInt();
    final pad = '1'.padRight(d + 1, '0');
    return int.parse(pad);
  }
}
