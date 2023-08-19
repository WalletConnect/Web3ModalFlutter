class EthUtil {
  static const ethMethods = [
    'eth_sendTransaction',
    // 'eth_signTransaction',
    'personal_sign',
    'eth_sign',
    'eth_signTypedData',
    'wallet_switchEthereumChain',
    'wallet_addEthereumChain',
  ];
  static const String chainChanged = 'chainChanged';
  static const String accountsChanged = 'accountsChanged';
  static const ethEvents = [
    chainChanged,
    accountsChanged,
  ];
}
