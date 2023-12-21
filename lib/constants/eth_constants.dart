class EthConstants {
  static const namespace = 'eip155';
  static const walletSwitchEthChain = 'wallet_switchEthereumChain';
  static const walletAddEthChain = 'wallet_addEthereumChain';
  static const requiredMethods = [
    'personal_sign',
    'eth_sendTransaction',
  ];
  static const coinbaseSupportedMethods = [
    ...requiredMethods,
    'eth_requestAccounts',
    'eth_signTypedData_v3',
    'eth_signTypedData_v4',
    'eth_signTransaction',
    walletSwitchEthChain,
    walletAddEthChain,
    'wallet_watchAsset',
  ];
  static const optionalMethods = [
    'eth_accounts',
    'eth_sendRawTransaction',
    'eth_sign',
    'eth_signTypedData',
    'wallet_getPermissions',
    'wallet_requestPermissions',
    'wallet_registerOnboarding',
    'wallet_scanQRCode',
    ...coinbaseSupportedMethods,
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
