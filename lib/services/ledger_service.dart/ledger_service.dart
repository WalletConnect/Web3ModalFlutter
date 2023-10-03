import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3modal_flutter/services/ledger_service.dart/i_ledger_service.dart';

class LedgerService extends ILedgerService {
  const LedgerService();

  @override
  Future<double> getBalance(String rpcUrl, String address) async {
    final client = Web3Client(rpcUrl, Client());
    final EtherAmount amount = await client.getBalance(
      EthereumAddress.fromHex(address),
    );

    return amount.getValueInUnit(EtherUnit.ether);
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
