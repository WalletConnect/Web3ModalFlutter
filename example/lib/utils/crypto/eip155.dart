import 'dart:convert';

import 'package:web3dart/web3dart.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_flutter_dapp/models/eth/ethereum_transaction.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/contract.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/test_data.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/web3dart_extension.dart';

enum EIP155UIMethods {
  personalSign,
  ethSignTypedData,
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
    // EIP155Methods.ethSign: 'eth_sign',
    // EIP155Methods.ethSignTransaction: 'eth_signTransaction',
    EIP155UIMethods.ethSignTypedData: 'eth_signTypedData',
    EIP155UIMethods.testContractCall: 'test_contractCall',
    EIP155UIMethods.ethSendTransaction: 'eth_sendTransaction',
    // EIP155Methods.walletSwitchEthereumChain: 'wallet_switchEthereumChain',
    // EIP155Methods.walletAddEthereumChain: 'wallet_addEthereumChain'
  };

  static final Map<EIP155Events, String> events = {
    EIP155Events.chainChanged: 'chainChanged',
    EIP155Events.accountsChanged: 'accountsChanged',
  };

  static Future<dynamic> callMethod({
    required IWeb3App web3App,
    required String topic,
    required EIP155UIMethods method,
    required String chainId,
    required String address,
  }) {
    switch (method) {
      case EIP155UIMethods.personalSign:
        return personalSign(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          address: address,
          data: testSignData,
        );
      case EIP155UIMethods.ethSignTypedData:
        return ethSignTypedData(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          address: address,
          data: testSignTypedData(int.parse(chainId.split(':')[1])),
        );
      case EIP155UIMethods.testContractCall:
        return testContractCall(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          address: address,
        );

      case EIP155UIMethods.ethSendTransaction:
        return ethSendTransaction(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          transaction: EthereumTransaction(
            from: address,
            to: address,
            value: '0x01',
          ),
        );
      // case EIP155UIMethods.ethSign:
      //   return ethSign(
      //     web3App: web3App,
      //     topic: topic,
      //     chainId: chainId,
      //     address: address,
      //     data: testSignData,
      //   );
      // case EIP155UIMethods.ethSignTransaction:
      //   return ethSignTransaction(
      //     web3App: web3App,
      //     topic: topic,
      //     chainId: chainId,
      //     transaction: EthereumTransaction(
      //       from: address,
      //       to: address,
      //       value: '0x01',
      //     ),
      //   );
      // case EIP155UIMethods.walletAddEthereumChain:
      // case EIP155UIMethods.walletSwitchEthereumChain:
      //   return walletSwitchChain(
      //     web3App: web3App,
      //     topic: topic,
      //     chainId: chainId,
      //     chainInfo: ChainData.chains.firstWhere(
      //       (element) => element.chainId == chainId,
      //       orElse: () => ChainData.chains.first,
      //     ),
      //   );
    }
  }

  static Future<dynamic> personalSign({
    required IWeb3App web3App,
    required String topic,
    required String chainId,
    required String address,
    required String data,
  }) async {
    return await web3App.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: methods[EIP155UIMethods.personalSign]!,
        params: [data, address],
      ),
    );
  }

  static Future<dynamic> ethSignTypedData({
    required IWeb3App web3App,
    required String topic,
    required String chainId,
    required String address,
    required String data,
  }) async {
    return await web3App.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: methods[EIP155UIMethods.ethSignTypedData]!,
        params: [address, data],
      ),
    );
  }

  static Future<dynamic> testContractCall({
    required IWeb3App web3App,
    required String topic,
    required String chainId,
    required String address,
  }) async {
    final W3MChainInfo ethChain = W3MChainPresets.chains['1']!;

    final DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(
          jsonEncode(ContractDetails.readContractAbi), 'Tether (USDT)'),
      EthereumAddress.fromHex(ContractDetails.contractAddress),
    );

    final ContractFunction balanceFunction = contract.function('balanceOf');

    final Transaction t = Transaction.callContract(
      contract: contract,
      function: balanceFunction,
      parameters: [EthereumAddress.fromHex(ContractDetails.balanceAddress)],
    );

    return await web3App.request(
      topic: topic,
      chainId: ethChain.namespace,
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        // Check the `web3dart_extension` file for this function
        params: [t.toJson(fromAddress: ContractDetails.balanceAddress)],
      ),
    );
  }

  static Future<dynamic> ethSendTransaction({
    required IWeb3App web3App,
    required String topic,
    required String chainId,
    required EthereumTransaction transaction,
  }) async {
    return await web3App.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: methods[EIP155UIMethods.ethSendTransaction]!,
        params: [transaction.toJson()],
      ),
    );
  }

  // static Future<dynamic> walletSwitchChain({
  //   required IWeb3App web3App,
  //   required String topic,
  //   required String chainId,
  //   required ChainMetadata chainInfo,
  // }) async {
  //   final int chainIdInt = int.parse(chainInfo.chainId);
  //   final String chainHex = chainIdInt.toRadixString(16);
  //   try {
  //     return await web3App.request(
  //       topic: topic,
  //       chainId: chainId,
  //       request: SessionRequestParams(
  //         method: methods[EIP155UIMethods.walletSwitchEthereumChain]!,
  //         params: [
  //           {
  //             'chainId': '0x$chainHex',
  //           },
  //         ],
  //       ),
  //     );
  //   } catch (e) {
  //     return await web3App.request(
  //       topic: topic,
  //       chainId: chainId,
  //       request: SessionRequestParams(
  //         method: 'wallet_addEthereumChain',
  //         params: [
  //           {
  //             'chainId': '0x$chainHex',
  //             'chainName': chainInfo.chainName,
  //             'nativeCurrency': {
  //               'name': chainInfo.tokenName,
  //               'symbol': chainInfo.tokenName,
  //               'decimals': 18,
  //             },
  //             'rpcUrls': [chainInfo.rpcUrl],
  //           },
  //         ],
  //       ),
  //     );
  //   }
  // }

  // static Future<dynamic> ethSign({
  //   required IWeb3App web3App,
  //   required String topic,
  //   required String chainId,
  //   required String address,
  //   required String data,
  // }) async {
  //   return await web3App.request(
  //     topic: topic,
  //     chainId: chainId,
  //     request: SessionRequestParams(
  //       method: methods[EIP155UIMethods.ethSign]!,
  //       params: [address, data],
  //     ),
  //   );
  // }

  // static Future<dynamic> ethSignTransaction({
  //   required IWeb3App web3App,
  //   required String topic,
  //   required String chainId,
  //   required EthereumTransaction transaction,
  // }) async {
  //   return await web3App.request(
  //     topic: topic,
  //     chainId: chainId,
  //     request: SessionRequestParams(
  //       method: methods[EIP155UIMethods.ethSignTransaction]!,
  //       params: [transaction.toJson()],
  //     ),
  //   );
  // }
}
