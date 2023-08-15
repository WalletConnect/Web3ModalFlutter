import 'package:flutter/services.dart';
import 'package:web3dart/crypto.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

extension TransactionX on Transaction {
  Map<String, dynamic> toJson({
    String? fromAddress,
  }) {
    return {
      'from': fromAddress ?? from?.hex,
      'to': to?.hex,
      'gas': '0x${maxGas!.toRadixString(16)}',
      'gasPrice': '0x${gasPrice?.getInWei.toRadixString(16) ?? '0'}',
      'value': '0x${value?.getInWei.toRadixString(16) ?? '0'}',
      'data': data != null ? bytesToHex(data!) : null,
      'nonce': nonce,
    };
  }
}

/// Store in the smart contract
Future<String> testContractStore({
  required Web3App walletConnect,
  required SessionData session,
  required String contractAddress,
  required int value,
}) async {
  // Getting the deployed contract using ABI and contract address
  final contract = DeployedContract(
    ContractAbi.fromJson(
      await rootBundle.loadString('assets/abis/testContract.abi.json'),
      'TestStorage', // The name of the contract
    ),
    EthereumAddress.fromHex(contractAddress),
  );

  // Create a transaction from contract, mint function and data uri.
  final Transaction transaction = Transaction.callContract(
    contract: contract, // The contract to call the function on
    function: contract.function('store'), // The function to call
    parameters: [
      // These are the parameters that are passed to the function
      value, // The value to store in the contract
    ],
  );

  // Send the transaction to the wallet to be executed
  return await walletConnect.request(
    topic: session.topic,
    chainId: NamespaceUtils.getChainFromAccount(
      session.namespaces.values.first.accounts.first,
    ),
    request: SessionRequestParams(
      method: 'eth_sendTransaction',
      params: transaction.toJson(
        // From address is the account of the session
        fromAddress: NamespaceUtils.getAccount(
          session.namespaces.values.first.accounts.first,
        ),
      ),
    ),
  );
}
