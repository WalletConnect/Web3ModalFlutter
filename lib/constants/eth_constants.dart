class EthConstants {
  static const ethRequiredMethods = [
    'personal_sign',
    'eth_signTypedData',
    'eth_sendTransaction',
  ];
  static const walletSwitchEthChain = 'wallet_switchEthereumChain';
  static const walletAddEthChain = 'wallet_addEthereumChain';
  static const ethOptionalMethods = [walletSwitchEthChain, walletAddEthChain];
  static const ethMethods = [...ethRequiredMethods, ...ethOptionalMethods];
  static const chainChanged = 'chainChanged';
  static const accountsChanged = 'accountsChanged';
  static const ethEvents = [chainChanged, accountsChanged];
}
