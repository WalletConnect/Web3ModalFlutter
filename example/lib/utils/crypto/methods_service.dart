import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/test_data/usdt_contract.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

// ignore: depend_on_referenced_packages
import 'package:convert/convert.dart';
// ignore: depend_on_referenced_packages
import 'package:bs58/bs58.dart';

import 'package:walletconnect_flutter_dapp/utils/crypto/test_data/aave_contract.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/test_data/test_data.dart';

enum SupportedMethods {
  personalSign,
  ethSendTransaction,
  requestAccounts,
  ethSignTypedData,
  ethSignTypedDataV3,
  ethSignTypedDataV4,
  ethSignTransaction,
  walletWatchAsset,
  solanaSignMessage,
  solanaSignTransaction;

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
      case solanaSignMessage:
        return 'solana_signMessage';
      case solanaSignTransaction:
        return 'solana_signTransaction';
    }
  }
}

class MethodsService {
  static SupportedMethods methodFromName(String name) {
    switch (name) {
      case 'personal_sign':
        return SupportedMethods.personalSign;
      case 'eth_signTypedData_v4':
        return SupportedMethods.ethSignTypedDataV4;
      case 'eth_sendTransaction':
        return SupportedMethods.ethSendTransaction;
      case 'eth_requestAccounts':
        return SupportedMethods.requestAccounts;
      case 'eth_signTypedData_v3':
        return SupportedMethods.ethSignTypedDataV3;
      case 'eth_signTypedData':
        return SupportedMethods.ethSignTypedData;
      case 'eth_signTransaction':
        return SupportedMethods.ethSignTransaction;
      case 'wallet_watchAsset':
        return SupportedMethods.walletWatchAsset;
      case 'solana_signMessage':
        return SupportedMethods.solanaSignMessage;
      case 'solana_signTransaction':
        return SupportedMethods.solanaSignTransaction;
      default:
        throw Exception('Unrecognized method');
    }
  }

  static Future<dynamic> callMethod({
    required W3MService w3mService,
    required String topic,
    required SupportedMethods method,
    required String chainId,
    required String address,
  }) {
    debugPrint(
        '[SampleDapp] callMethod, topic: $topic, method: ${method.name}, chainId: $chainId, address: $address');
    final cid = chainId.split(':')[1];
    switch (method) {
      case SupportedMethods.requestAccounts:
        return _requestAccounts(
          w3mService: w3mService,
        );
      case SupportedMethods.personalSign:
        return _personalSign(
          w3mService: w3mService,
          message: testSignData,
        );
      case SupportedMethods.ethSignTypedDataV3:
        return _ethSignTypedDataV3(
          w3mService: w3mService,
          data: jsonEncode(typeDataV3(int.parse(cid))),
        );
      case SupportedMethods.ethSignTypedData:
        return _ethSignTypedData(
          w3mService: w3mService,
          data: jsonEncode(typedData()),
        );
      case SupportedMethods.ethSignTypedDataV4:
        return _ethSignTypedDataV4(
          w3mService: w3mService,
          data: jsonEncode(typeDataV4(int.parse(cid))),
        );
      case SupportedMethods.ethSignTransaction:
      case SupportedMethods.ethSendTransaction:
        return _ethSendTransaction(
          w3mService: w3mService,
          transaction: Transaction(
            from: EthereumAddress.fromHex(address),
            to: EthereumAddress.fromHex(
              '0x59e2f66C0E96803206B6486cDb39029abAE834c0',
            ),
            value: EtherAmount.fromInt(EtherUnit.finney, 11), // == 0.011
          ),
          method: method,
        );
      case SupportedMethods.walletWatchAsset:
        return _walletWatchAsset(
          w3mService: w3mService,
        );
      case SupportedMethods.solanaSignMessage:
        return _solanaSignMessage(
          w3mService: w3mService,
          message: testSignData,
        );
      case SupportedMethods.solanaSignTransaction:
        return _solanaSignTransaction(
          w3mService: w3mService,
          address: address,
          isV0: true,
        );
    }
  }

  static Future<dynamic> _requestAccounts({
    required W3MService w3mService,
  }) async {
    return await w3mService.request(
      topic: w3mService.session!.topic,
      chainId: w3mService.selectedChain!.chainId,
      request: SessionRequestParams(
        method: SupportedMethods.requestAccounts.name,
        params: [],
      ),
    );
  }

  static Future<dynamic> _personalSign({
    required W3MService w3mService,
    required String message,
  }) async {
    final bytes = utf8.encode(message);
    final encoded = hex.encode(bytes);

    return await w3mService.request(
      topic: w3mService.session!.topic,
      chainId: w3mService.selectedChain!.chainId,
      request: SessionRequestParams(
        method: SupportedMethods.personalSign.name,
        params: [
          '0x$encoded',
          w3mService.session!.address!,
        ],
      ),
    );
  }

  static Future<dynamic> _ethSignTypedData({
    required W3MService w3mService,
    required String data,
  }) async {
    return await w3mService.request(
      topic: w3mService.session!.topic,
      chainId: w3mService.selectedChain!.chainId,
      request: SessionRequestParams(
        method: SupportedMethods.ethSignTypedData.name,
        params: [
          data,
          w3mService.session!.address!,
        ],
      ),
    );
  }

  static Future<dynamic> _ethSignTypedDataV3({
    required W3MService w3mService,
    required String data,
  }) async {
    return await w3mService.request(
      topic: w3mService.session!.topic,
      chainId: w3mService.selectedChain!.chainId,
      request: SessionRequestParams(
        method: SupportedMethods.ethSignTypedDataV3.name,
        params: [
          data,
          w3mService.session!.address!,
        ],
      ),
    );
  }

  static Future<dynamic> _ethSignTypedDataV4({
    required W3MService w3mService,
    required String data,
  }) async {
    return await w3mService.request(
      topic: w3mService.session!.topic,
      chainId: w3mService.selectedChain!.chainId,
      request: SessionRequestParams(
        method: SupportedMethods.ethSignTypedDataV4.name,
        params: [
          data,
          w3mService.session!.address!,
        ],
      ),
    );
  }

  static Future<dynamic> _ethSendTransaction({
    required W3MService w3mService,
    required Transaction transaction,
    required SupportedMethods method,
  }) async {
    return await w3mService.request(
      topic: w3mService.session!.topic,
      chainId: w3mService.selectedChain!.chainId,
      request: SessionRequestParams(
        method: method.name,
        params: [
          transaction.toJson(),
        ],
      ),
    );
  }

  static Future<dynamic> _walletWatchAsset({
    required W3MService w3mService,
  }) async {
    return await w3mService.request(
      topic: w3mService.session!.topic,
      chainId: w3mService.selectedChain!.chainId,
      request: SessionRequestParams(
        method: SupportedMethods.walletWatchAsset.name,
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

  // Example of calling `transfer` function from AAVE token Smart Contract
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
          contract: deployedContract,
        );
      case 'write':
        // return await w3mService.requestWriteContract(
        //   topic: w3mService.session?.topic ?? '',
        //   chainId: 'eip155:11155111',
        //   deployedContract: deployedContract,
        //   functionName: 'subscribe',
        //   parameters: [],
        //   transaction: Transaction(
        //     from: EthereumAddress.fromHex(w3mService.session!.address!),
        //     value: EtherAmount.fromInt(EtherUnit.finney, 1),
        //   ),
        // );
        // we first call `decimals` function, which is a read function,
        // to check how much decimal we need to use to parse the amount value
        final decimals = await w3mService.requestReadContract(
          topic: w3mService.session!.topic,
          chainId: w3mService.selectedChain!.namespace,
          deployedContract: deployedContract,
          functionName: 'decimals',
        );
        final d = (decimals.first as BigInt);
        final requestValue = _formatValue(0.01, decimals: d);
        // now we call `transfer` write function with the parsed value.
        return w3mService.requestWriteContract(
          topic: w3mService.session!.topic,
          chainId: w3mService.selectedChain!.namespace,
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

  // Example of calling `transfer` function from USDT token Smart Contract
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
          contract: deployedContract,
        );
      case 'write':
        // we first call `decimals` function, which is a read function,
        // to check how much decimal we need to use to parse the amount value
        final decimals = await w3mService.requestReadContract(
          topic: w3mService.session!.topic,
          chainId: w3mService.selectedChain!.namespace,
          deployedContract: deployedContract,
          functionName: 'decimals',
        );
        final d = (decimals.first as BigInt);
        final requestValue = _formatValue(0.23, decimals: d);
        // now we call `transfer` write function with the parsed value.
        return w3mService.requestWriteContract(
          topic: w3mService.session!.topic,
          chainId: w3mService.selectedChain!.namespace,
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
    required DeployedContract contract,
  }) async {
    final results = await Future.wait([
      // results[0]
      w3mService.requestReadContract(
        topic: w3mService.session!.topic,
        chainId: w3mService.selectedChain!.namespace,
        deployedContract: contract,
        functionName: 'name',
      ),
      // results[1]
      w3mService.requestReadContract(
        topic: w3mService.session!.topic,
        chainId: w3mService.selectedChain!.namespace,
        deployedContract: contract,
        functionName: 'totalSupply',
      ),
      // results[2]
      w3mService.requestReadContract(
        topic: w3mService.session!.topic,
        chainId: w3mService.selectedChain!.namespace,
        deployedContract: contract,
        functionName: 'balanceOf',
        parameters: [
          EthereumAddress.fromHex(w3mService.session!.address!),
        ],
      ),
      // results[4]
      w3mService.requestReadContract(
        topic: w3mService.session!.topic,
        chainId: w3mService.selectedChain!.namespace,
        deployedContract: contract,
        functionName: 'decimals',
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

  // SOLANA METHODS

  static Future<dynamic> _solanaSignMessage({
    required W3MService w3mService,
    required String message,
  }) async {
    final bytes = utf8.encode(message);
    final encoded = base58.encode(bytes);

    return await w3mService.request(
      topic: w3mService.session!.topic,
      chainId: w3mService.selectedChain!.chainId,
      request: SessionRequestParams(
        method: SupportedMethods.solanaSignMessage.name,
        params: {
          'pubkey': w3mService.session!.address!,
          'message': encoded,
        },
      ),
    );
  }

  static Future<dynamic> _solanaSignTransaction({
    required W3MService w3mService,
    required String address,
    bool isV0 = true,
  }) async {
    return await w3mService.request(
      topic: w3mService.session!.topic,
      chainId: w3mService.selectedChain!.chainId,
      request: SessionRequestParams(
        method: SupportedMethods.solanaSignTransaction.name,
        params: {
          "transaction":
              "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAQABA8oGprM4KFNdgDJcXvItmbIeBJ29nZ+Y9t2KatWbwffpdaMhhWgGf/cOLK4MfSqKoh7TzOlbq+4eA+l1aEoKxIQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACTY9ZvhErKjznLrlIyC4FZnRbCLD05FhimRRroeKDqJAQICAAEMAgAAAICWmAAAAAAAAA==",
          "feePayer": address,
          "pubkey": address,
          "recentBlockhash": "H32Ss1hxpP2ZJM4whREVNyUWRgzFLVA97UXJUjBrEsgx",
          "instructions": [
            {
              "programId": "11111111111111111111111111111111",
              "data": [2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
              "keys": [
                {
                  "isSigner": true,
                  "isWritable": true,
                  "pubkey": address,
                },
                {
                  "isSigner": false,
                  "isWritable": true,
                  "pubkey": "8vCyX7oB6Pc3pbWMGYYZF5pbSnAdQ7Gyr32JqxqCy8ZR"
                }
              ]
            }
          ]
        },
      ),
    );
  }
}
