// import 'package:json_annotation/json_annotation.dart';

// part 'ethereum_transaction.g.dart';

// @JsonSerializable(includeIfNull: false)
class EthereumTransaction {
  final String from;
  final String to;
  final String value;
  final String? nonce;
  final String? gasPrice;
  final String? maxFeePerGas;
  final String? maxPriorityFeePerGas;
  final String? gas;
  final String? gasLimit;
  final String? data;

  EthereumTransaction({
    required this.from,
    required this.to,
    required this.value,
    this.nonce,
    this.gasPrice,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    this.gas,
    this.gasLimit,
    this.data,
  });

  // factory EthereumTransaction.fromJson(Map<String, dynamic> json) {
  //   return EthereumTransaction(from: from, to: to, value: value,);
  // }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'from': from,
      'to': to,
      'value': value,
    };
    if (nonce != null) {
      json['nonce'] = nonce;
    }
    if (gasPrice != null) {
      json['gasPrice'] = gasPrice;
    }
    if (maxFeePerGas != null) {
      json['maxFeePerGas'] = maxFeePerGas;
    }
    if (maxPriorityFeePerGas != null) {
      json['maxPriorityFeePerGas'] = maxPriorityFeePerGas;
    }
    if (gas != null) {
      json['gas'] = gas;
    }
    if (gasLimit != null) {
      json['gasLimit'] = gasLimit;
    }
    if (data != null) {
      json['data'] = data;
    }
    return json;
  }

  @override
  String toString() {
    return 'WCEthereumTransaction(from: $from, to: $to, nonce: $nonce, gasPrice: $gasPrice, maxFeePerGas: $maxFeePerGas, maxPriorityFeePerGas: $maxPriorityFeePerGas, gas: $gas, gasLimit: $gasLimit, value: $value, data: $data)';
  }
}
