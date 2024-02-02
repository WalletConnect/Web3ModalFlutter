import 'package:http/http.dart';
import 'package:web3modal_flutter/services/ledger_service/i_ledger_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class LedgerService extends ILedgerService {
  @override
  Future<double> getBalance(String rpcUrl, String address) async {
    try {
      final client = Web3Client(rpcUrl, Client());
      final amount = await client.getBalance(EthereumAddress.fromHex(address));
      return amount.getValueInUnit(EtherUnit.ether);
    } catch (e, s) {
      W3MLoggerUtil.logger.e(
        '[$runtimeType] getBalance error',
        error: e,
        stackTrace: s,
      );
      return 0.0;
    }
  }

  @override
  Future<String> fetchEnsName(String rpcUrl, String address) async {
    return '';
  }

  @override
  Future<String> fetchEnsAvatar(String rpcUrl, String address) async {
    return '';
  }
}
