import 'dart:convert';

import 'package:web3dart/web3dart.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_flutter_dapp/models/eth/ethereum_transaction.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/contract.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/test_data.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/web3dart_extension.dart';

enum EIP155UIMethods {
  personalSign,
  ethSignTypedDataV4,
  ethSendTransaction,
  testContractCall,
}

enum EIP155Events {
  chainChanged,
  accountsChanged,
}

extension EIP155MethodsX on EIP155UIMethods {
  String? get value => EIP155.methods[this];
}

extension EIP155MethodsStringX on String {
  EIP155UIMethods? toEip155Method() {
    final entries = EIP155.methods.entries.where(
      (element) => element.value == this,
    );
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}

extension EIP155EventsX on EIP155Events {
  String? get value => EIP155.events[this];
}

extension EIP155EventsStringX on String {
  EIP155Events? toEip155Event() {
    final entries = EIP155.events.entries.where(
      (element) => element.value == this,
    );
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}

class EIP155 {
  static const ethRequiredMethods = [
    'personal_sign',
    'eth_signTypedData',
    'eth_sendTransaction',
  ];
  static const walletSwitchEthChain = 'wallet_switchEthereumChain';
  static const walletAddEthChain = 'wallet_addEthereumChain';
  static const ethOptionalMethods = [
    walletSwitchEthChain,
    walletAddEthChain,
  ];
  static const allMethods = [
    ...ethRequiredMethods,
    ...ethOptionalMethods,
  ];
  static const ethEvents = [
    'chainChanged',
    'accountsChanged',
  ];

  static final Map<EIP155UIMethods, String> methods = {
    EIP155UIMethods.personalSign: 'personal_sign',
    EIP155UIMethods.ethSignTypedDataV4: 'eth_signTypedData_v4',
    EIP155UIMethods.testContractCall: 'test_contractCall',
    EIP155UIMethods.ethSendTransaction: 'eth_sendTransaction',
  };

  static final Map<EIP155Events, String> events = {
    EIP155Events.chainChanged: 'chainChanged',
    EIP155Events.accountsChanged: 'accountsChanged',
  };

  static Future<dynamic> callMethod({
    required W3MService w3mService,
    required String topic,
    required EIP155UIMethods method,
    required String chainId,
    required String address,
  }) {
    final id = int.parse(chainId.split(':')[1]);
    switch (method) {
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
          data: typedData(id),
        );
      case EIP155UIMethods.testContractCall:
        return testContractCall(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          address: address,
        );

      case EIP155UIMethods.ethSendTransaction:
        return ethSendTransaction(
          w3mService: w3mService,
          topic: topic,
          chainId: chainId,
          transaction: EthereumTransaction(
            from: address,
            to: address,
            value: '0x01',
            data: '0x', // to make it work with some wallets
          ),
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
    return await w3mService.web3App!.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: methods[EIP155UIMethods.personalSign]!,
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
    return await w3mService.web3App!.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: methods[EIP155UIMethods.ethSignTypedDataV4]!,
        params: [address, data],
      ),
    );
  }

  static Future<dynamic> testContractCall({
    required W3MService w3mService,
    required String topic,
    required String chainId,
    required String address,
  }) async {
    final ethChain = W3MChainPresets.chains['1']!;
    final contract = DeployedContract(
      ContractAbi.fromJson(
          jsonEncode(ContractDetails.readContractAbi), 'Tether (USDT)'),
      EthereumAddress.fromHex(ContractDetails.contractAddress),
    );

    final balanceFunction = contract.function('balanceOf');

    final transaction = Transaction.callContract(
      contract: contract,
      function: balanceFunction,
      parameters: [EthereumAddress.fromHex(ContractDetails.balanceAddress)],
    );

    return await w3mService.web3App!.request(
      topic: topic,
      chainId: ethChain.namespace,
      request: SessionRequestParams(
        method: methods[EIP155UIMethods.ethSendTransaction]!,
        // Check the `web3dart_extension` file for this function
        params: [
          transaction.toJson(fromAddress: ContractDetails.balanceAddress),
        ],
      ),
    );
  }

  static Future<dynamic> ethSendTransaction({
    required W3MService w3mService,
    required String topic,
    required String chainId,
    required EthereumTransaction transaction,
  }) async {
    return await w3mService.web3App!.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: methods[EIP155UIMethods.ethSendTransaction]!,
        params: [transaction.toJson()],
      ),
    );
  }
}
