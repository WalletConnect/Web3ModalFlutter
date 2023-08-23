import 'package:sign/models/eth/ethereum_transaction.dart';
import 'package:sign/utils/crypto/test_data.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

enum EIP155Methods {
  personalSign,
  ethSign,
  ethSignTransaction,
  ethSignTypedData,
  ethSendTransaction,
  walletSwitchEthereumChain,
  walletAddEthereumChain,
}

enum EIP155Events {
  chainChanged,
  accountsChanged,
}

extension EIP155MethodsX on EIP155Methods {
  String? get value => EIP155.methods[this];
}

extension EIP155MethodsStringX on String {
  EIP155Methods? toEip155Method() {
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
  static final Map<EIP155Methods, String> methods = {
    EIP155Methods.personalSign: 'personal_sign',
    // EIP155Methods.ethSign: 'eth_sign',
    // EIP155Methods.ethSignTransaction: 'eth_signTransaction',
    // EIP155Methods.ethSignTypedData: 'eth_signTypedData',
    EIP155Methods.ethSendTransaction: 'eth_sendTransaction',
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
    required EIP155Methods method,
    required String chainId,
    required String address,
  }) {
    switch (method) {
      case EIP155Methods.personalSign:
        return personalSign(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          address: address,
          data: testSignData,
        );
      case EIP155Methods.ethSign:
        return ethSign(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          address: address,
          data: testSignData,
        );
      case EIP155Methods.ethSignTypedData:
        return ethSignTypedData(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          address: address,
          data: typedData,
        );
      case EIP155Methods.ethSignTransaction:
        return ethSignTransaction(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          transaction: EthereumTransaction(
            from: address,
            to: address,
            value: '0x01',
          ),
        );
      case EIP155Methods.ethSendTransaction:
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
      case EIP155Methods.walletAddEthereumChain:
      case EIP155Methods.walletSwitchEthereumChain:
        return walletSwitchChain(
          web3App: web3App,
          topic: topic,
          chainId: chainId,
          chainInfo: ChainData.chainPresets[chainId.split(':')[1]]!,
        );
    }
  }

  static Future<dynamic> walletSwitchChain({
    required IWeb3App web3App,
    required String topic,
    required String chainId,
    required W3MChainInfo chainInfo,
  }) async {
    final int chainIdInt = int.parse(chainInfo.chainId);
    final String chainHex = chainIdInt.toRadixString(16);
    try {
      return await web3App.request(
        topic: topic,
        chainId: chainId,
        request: SessionRequestParams(
          method: methods[EIP155Methods.walletSwitchEthereumChain]!,
          params: [
            {
              'chainId': '0x$chainHex',
            },
          ],
        ),
      );
    } catch (e) {
      return await web3App.request(
        topic: topic,
        chainId: chainId,
        request: SessionRequestParams(
          method: 'wallet_addEthereumChain',
          params: [
            {
              'chainId': '0x$chainHex',
              'chainName': chainInfo.chainName,
              'nativeCurrency': {
                'name': chainInfo.tokenName,
                'symbol': chainInfo.tokenName,
                'decimals': 18,
              },
              'rpcUrls': [chainInfo.rpcUrl],
            },
          ],
        ),
      );
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
        method: methods[EIP155Methods.personalSign]!,
        params: [data, address],
      ),
    );
  }

  static Future<dynamic> ethSign({
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
        method: methods[EIP155Methods.ethSign]!,
        params: [address, data],
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
        method: methods[EIP155Methods.ethSignTypedData]!,
        params: [address, data],
      ),
    );
  }

  static Future<dynamic> ethSignTransaction({
    required IWeb3App web3App,
    required String topic,
    required String chainId,
    required EthereumTransaction transaction,
  }) async {
    return await web3App.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: methods[EIP155Methods.ethSignTransaction]!,
        params: [transaction.toJson()],
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
        method: methods[EIP155Methods.ethSendTransaction]!,
        params: [transaction.toJson()],
      ),
    );
  }
}
