import 'package:web3modal_flutter/web3modal_flutter.dart';

extension TransactionX on Transaction {
  Map<String, dynamic> toJson({
    String? fromAddress,
  }) {
    return {
      'from': fromAddress ?? from?.hex,
      'to': to?.hex,
      'gas': maxGas != null ? '0x${maxGas!.toRadixString(16)}' : null,
      'gasPrice': '0x${gasPrice?.getInWei.toRadixString(16) ?? '0'}',
      'value': '0x${value?.getInWei.toRadixString(16) ?? '0'}',
      'data': data != null ? bytesToHex(data!) : null,
      'nonce': nonce,
    };
  }
}
