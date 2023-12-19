class EthConstants {
  static const namespace = 'eip155';
  static const walletSwitchEthChain = 'wallet_switchEthereumChain';
  static const walletAddEthChain = 'wallet_addEthereumChain';
  static const requiredMethods = [
    'eth_sendTransaction',
    'personal_sign',
  ];
  static const coinbaseMethods = [
    'eth_requestAccounts',
    'eth_signTransaction',
    'eth_signTypedData_v3',
    'eth_signTypedData_v4',
    'eth_sendTransaction',
    walletSwitchEthChain,
    walletAddEthChain,
  ];
  static const optionalMethods = [
    'eth_accounts',
    'eth_sendRawTransaction',
    'eth_sign',
    'eth_signTypedData',
    'wallet_getPermissions',
    'wallet_requestPermissions',
    'wallet_registerOnboarding',
    'wallet_watchAsset',
    'wallet_scanQRCode',
    ...coinbaseMethods,
  ];
  static const allMethods = [...requiredMethods, ...optionalMethods];
  //
  static const chainChanged = 'chainChanged';
  static const accountsChanged = 'accountsChanged';
  static const requiredEvents = [
    chainChanged,
    accountsChanged,
  ];
  static const optionalEvents = [
    'message',
    'disconnect',
    'connect',
  ];
  static const allEvents = [...requiredEvents, ...optionalEvents];
}
