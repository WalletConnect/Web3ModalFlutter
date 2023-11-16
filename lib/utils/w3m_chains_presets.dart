import 'package:web3modal_flutter/models/w3m_chain_info.dart';

class W3MChainPresets {
  /// All RPC urls were found here: https://rpc.info/
  static Map<String, W3MChainInfo> chains = {
    '1': W3MChainInfo(
      chainName: 'Ethereum',
      namespace: 'eip155:1',
      chainId: '1',
      chainIcon: chainImagesId['1'],
      tokenName: 'ETH',
      rpcUrl: 'https://eth.drpc.org',
      blockExplorer: W3MBlockExplorer(
        name: 'Etherscan',
        url: 'https://etherscan.io',
      ),
    ),
    '42161': W3MChainInfo(
      chainName: 'Arbitrum',
      namespace: 'eip155:42161',
      chainId: '42161',
      chainIcon: chainImagesId['42161'],
      tokenName: 'ARB',
      rpcUrl: 'https://arbitrum.blockpi.network/v1/rpc/public',
      blockExplorer: W3MBlockExplorer(
        name: 'Arbiscan',
        url: 'https://arbiscan.io/',
      ),
    ),
    '137': W3MChainInfo(
      chainName: 'Polygon',
      namespace: 'eip155:137',
      chainId: '137',
      chainIcon: chainImagesId['137'],
      tokenName: 'MATIC',
      rpcUrl: 'https://polygon.drpc.org',
      blockExplorer: W3MBlockExplorer(
        name: 'Explorer',
        url: 'https://polygonscan.com',
      ),
    ),
    '43114': W3MChainInfo(
      chainName: 'Avalanche',
      namespace: 'eip155:43114',
      chainId: '43114',
      chainIcon: chainImagesId['43114'],
      tokenName: 'AVAX',
      rpcUrl: 'https://api.avax.network/ext/bc/C/rpc',
      blockExplorer: W3MBlockExplorer(
        name: 'Snowtrace',
        url: 'https://snowtrace.io',
      ),
    ),
    '56': W3MChainInfo(
      chainName: 'Binance Smart Chain',
      namespace: 'eip155:56',
      chainId: '56',
      chainIcon: chainImagesId['56'],
      tokenName: 'BNB',
      rpcUrl: 'https://bsc-dataseed.binance.org/',
      blockExplorer: W3MBlockExplorer(
        name: 'BSC Scan',
        url: 'https://bscscan.com',
      ),
    ),
    '10': W3MChainInfo(
      chainName: 'Optimism',
      namespace: 'eip155:10',
      chainId: '10',
      chainIcon: chainImagesId['10'],
      tokenName: 'OP',
      rpcUrl: 'https://mainnet.optimism.io/',
    ),
    '250': W3MChainInfo(
      chainName: 'Fantom',
      namespace: 'eip155:250',
      chainId: '250',
      chainIcon: chainImagesId['250'],
      tokenName: 'FTM',
      rpcUrl: 'https://rpc.ftm.tools/',
      blockExplorer: W3MBlockExplorer(
        name: 'FTM Scan',
        url: 'https://ftmscan.com',
      ),
    ),
    '9001': W3MChainInfo(
      chainName: 'EVMos',
      namespace: 'eip155:9001',
      chainId: '9001',
      chainIcon: chainImagesId['9001'],
      tokenName: 'EVMOS',
      rpcUrl: 'https://evmos-evm.publicnode.com',
    ),
    '4689': W3MChainInfo(
      chainName: 'Iotx',
      namespace: 'eip155:4689',
      chainId: '4689',
      chainIcon: chainImagesId['4689'],
      tokenName: 'IOTX',
      rpcUrl: 'https://rpc.ankr.com/iotex',
      blockExplorer: W3MBlockExplorer(
        name: 'IOTEX Scan',
        url: 'https://iotexscan.io',
      ),
    ),
    '1088': W3MChainInfo(
      chainName: 'Metis',
      namespace: 'eip155:1088',
      chainId: '1088',
      chainIcon: chainImagesId['1088'],
      tokenName: 'METIS',
      rpcUrl: 'https://metis-mainnet.public.blastapi.io',
      blockExplorer: W3MBlockExplorer(
        name: 'Andromeda Explorer',
        url: 'https://andromeda-explorer.metis.io',
      ),
    ),
  };

  static Map<String, String> chainImagesId = {
    // Ethereum
    '1': '692ed6ba-e569-459a-556a-776476829e00',
    // Arbitrum
    '42161': '600a9a04-c1b9-42ca-6785-9b4b6ff85200',
    // Avalanche
    '43114': '30c46e53-e989-45fb-4549-be3bd4eb3b00',
    // Binance Smart Chain
    '56': '93564157-2e8e-4ce7-81df-b264dbee9b00',
    // Fantom
    '250': '06b26297-fe0c-4733-5d6b-ffa5498aac00',
    // Optimism
    '10': 'ab9c186a-c52f-464b-2906-ca59d760a400',
    // Polygon
    '137': '41d04d42-da3b-4453-8506-668cc0727900',
    // Gnosis
    '100': '02b53f6a-e3d4-479e-1cb4-21178987d100',
    // EVMos
    '9001': 'f926ff41-260d-4028-635e-91913fc28e00',
    // ZkSync
    '324': 'b310f07f-4ef7-49f3-7073-2a0a39685800',
    // Filecoin
    '314': '5a73b3dd-af74-424e-cae0-0de859ee9400',
    // Iotx
    '4689': '34e68754-e536-40da-c153-6ef2e7188a00',
    // Metis,
    '1088': '3897a66d-40b9-4833-162f-a2c90531c900',
    // Moonbeam
    '1284': '161038da-44ae-4ec7-1208-0ea569454b00',
    // Moonriver
    '1285': 'f1d73bb6-5450-4e18-38f7-fb6484264a00',
    // Zora
    '7777777': '845c60df-d429-4991-e687-91ae45791600',
    // Celo
    '42220': 'ab781bbc-ccc6-418d-d32d-789b15da1f00',
    // Base
    '8453': '7289c336-3981-4081-c5f4-efc26ac64a00',
    // Aurora
    '1313161554': '3ff73439-a619-4894-9262-4470c773a100'
  };
}
