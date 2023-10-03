abstract class ILedgerService {
  Future<double> getBalance(String rpcUrl, String address);

  Future<String> fetchEnsName(String rpcUrl, String address);

  Future<String> fetchEnsAvatar(String rpcUrl, String address);
}
