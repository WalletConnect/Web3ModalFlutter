class Chain {
  final int id;
  final String name;

  const Chain({
    required this.id,
    required this.name,
  });
}

class ChainList {
  static const List<Chain> chainList = [
    Chain(id: 1, name: 'Ethereum'),
    Chain(id: 3, name: 'Ropsten'),
    Chain(id: 4, name: 'Rinkeby'),
    Chain(id: 5, name: 'Goerli'),
    Chain(id: 42, name: 'Kovan'),
    Chain(id: 137, name: 'Polygon'),
    Chain(id: 80001, name: 'Polygon Mumbai'),
    Chain(id: 56, name: 'Binance Smart Chain'),
    Chain(id: 97, name: 'Binance Smart Chain Testnet'),
    Chain(id: 100, name: 'xDai'),
    Chain(id: 43114, name: 'Avalanche'),
    Chain(id: 43113, name: 'Avalanche Fuji'),
    Chain(id: 42220, name: 'Celo'),
    Chain(id: 1666600000, name: 'Harmony'),
    Chain(id: 1666700000, name: 'Harmony Testnet'),
    Chain(id: 250, name: 'Fantom'),
    Chain(id: 4002, name: 'Fantom Testnet'),
    // Chain(id: 122, name: 'Fuse'),
    // Chain(id: 1284, name: 'Moonbeam'),
    // Chain(id: 1285, name: 'Moonriver'),
    // Chain(id: 40, name: 'Telos'),
    // Chain(id: 41, name: 'Telos Testnet'),
    // Chain(id: 42161, name: 'Arbitrum One'),
    // Chain(id: 42170, name: 'Arbitrum Nova'),
    // Chain(id: 421613, name: 'Arbitrum Goerli'),
    // Chain(id: 1313161554, name: 'Aurora'),
    // Chain(id: 1313161555, name: 'Aurora Testnet'),
    // Chain(id: 8453, name: 'Base'),
    // Chain(id: 84531, name: 'Base Goerli'),
    // Chain(id: 641230, name: 'Bear Network Chain Mainnet'),
    // Chain(id: 751230, name: 'Bear Network Chain Testnet'),
    // Chain(id: 288, name: 'Boba Network'),
    // Chain(id: 1039, name: 'Bronos'),
    // Chain(id: 1038, name: 'Bronos Testnet'),
    // Chain(id: 56, name: 'BNB Smart Chain'),
    // Chain(id: 97, name: 'Binance Smart Chain Testnet'),
    // Chain(id: 4999, name: 'BlackFort Exchange Network'),
    // Chain(id: 4777, name: 'BlackFort Exchange Network Testnet'),
    // Chain(id: 7700, name: 'Canto'),
  ];
}
