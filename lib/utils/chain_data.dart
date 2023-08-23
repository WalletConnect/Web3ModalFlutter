import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/models/w3m_chain_info.dart';
import 'package:web3modal_flutter/utils/eth_util.dart';

class ChainData {
  /// All RPC urls were found here: https://rpc.info/
  static Map<String, W3MChainInfo> chainPresets = {
    '1': W3MChainInfo(
      chainName: 'Ethereum',
      namespace: 'eip155:1',
      chainId: '1',
      chainIcon: '692ed6ba-e569-459a-556a-776476829e00',
      tokenName: 'ETH',
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethRequiredMethods,
          chains: ['eip155:1'],
          events: EthUtil.ethEvents,
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethOptionalMethods,
          chains: ['eip155:1'],
          events: [],
        ),
      },
      rpcUrl: 'https://eth.drpc.org',
    ),
    '42161': W3MChainInfo(
      chainName: 'Arbitrum',
      namespace: 'eip155:42161',
      chainId: '42161',
      chainIcon: '600a9a04-c1b9-42ca-6785-9b4b6ff85200',
      tokenName: 'ARB',
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethRequiredMethods,
          chains: ['eip155:42161'],
          events: EthUtil.ethEvents,
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethOptionalMethods,
          chains: ['eip155:42161'],
          events: [],
        ),
      },
      rpcUrl: 'https://arbitrum.blockpi.network/v1/rpc/public',
    ),
    '43114': W3MChainInfo(
      chainName: 'Avalanche',
      namespace: 'eip155:43114',
      chainId: '43114',
      chainIcon: '30c46e53-e989-45fb-4549-be3bd4eb3b00',
      tokenName: 'AVAX',
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethRequiredMethods,
          chains: ['eip155:43114'],
          events: EthUtil.ethEvents,
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethOptionalMethods,
          chains: ['eip155:43114'],
          events: [],
        ),
      },
      rpcUrl: 'https://api.avax.network/ext/bc/C/rpc',
    ),
    '56': W3MChainInfo(
      chainName: 'Binance Smart Chain',
      namespace: 'eip155:56',
      chainId: '56',
      chainIcon: '93564157-2e8e-4ce7-81df-b264dbee9b00',
      tokenName: 'BNB',
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethRequiredMethods,
          chains: ['eip155:56'],
          events: EthUtil.ethEvents,
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethOptionalMethods,
          chains: ['eip155:56'],
          events: [],
        ),
      },
      rpcUrl: 'https://bsc-dataseed.binance.org/',
    ),
    '250': W3MChainInfo(
      chainName: 'Fantom',
      namespace: 'eip155:250',
      chainId: '250',
      chainIcon: '06b26297-fe0c-4733-5d6b-ffa5498aac00',
      tokenName: 'FTM',
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethRequiredMethods,
          chains: ['eip155:250'],
          events: EthUtil.ethEvents,
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethOptionalMethods,
          chains: ['eip155:50'],
          events: [],
        ),
      },
      rpcUrl: 'https://rpc.ftm.tools/',
    ),
    '10': W3MChainInfo(
      chainName: 'Optimism',
      namespace: 'eip155:10',
      chainId: '10',
      chainIcon: 'ab9c186a-c52f-464b-2906-ca59d760a400',
      tokenName: 'OP',
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethRequiredMethods,
          chains: ['eip155:10'],
          events: EthUtil.ethEvents,
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethOptionalMethods,
          chains: ['eip155:10'],
          events: [],
        ),
      },
      rpcUrl: 'https://mainnet.optimism.io/',
    ),
    '137': W3MChainInfo(
      chainName: 'Polygon',
      namespace: 'eip155:137',
      chainId: '137',
      chainIcon: '41d04d42-da3b-4453-8506-668cc0727900',
      tokenName: 'MATIC',
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethRequiredMethods,
          chains: ['eip155:137'],
          events: EthUtil.ethEvents,
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethOptionalMethods,
          chains: ['eip155:137'],
          events: [],
        ),
      },
      rpcUrl: 'https://polygon.drpc.org',
    ),
    // '100': W3MChainInfo(
    //   chainName: 'Gnosis',
    //   chainId: '100',
    //   chainIcon: '02b53f6a-e3d4-479e-1cb4-21178987d100',
    //   tokenName: 'ETH',
    // ),
    '9001': W3MChainInfo(
      chainName: 'EVMos',
      namespace: 'eip155:9001',
      chainId: '9001',
      chainIcon: 'f926ff41-260d-4028-635e-91913fc28e00',
      tokenName: 'EVMOS',
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethRequiredMethods,
          chains: ['eip155:9001'],
          events: EthUtil.ethEvents,
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethOptionalMethods,
          chains: ['eip155:9001'],
          events: [],
        ),
      },
      rpcUrl: 'https://eth.bd.evmos.org:8545',
    ),
    // '324': W3MChainInfo(
    //   chainName: 'ZkSync',
    //   chainId: '324',
    //   chainIcon: 'b310f07f-4ef7-49f3-7073-2a0a39685800',
    //   tokenName: 'ETH',
    // ),
    // '314': W3MChainInfo(
    //   chainName: 'Filecoin',
    //   chainId: '314',
    //   chainIcon: '5a73b3dd-af74-424e-cae0-0de859ee9400',
    //   tokenName: 'ETH',
    // ),
    '4689': W3MChainInfo(
      chainName: 'Iotx',
      namespace: 'eip155:4689',
      chainId: '4689',
      chainIcon: '34e68754-e536-40da-c153-6ef2e7188a00',
      tokenName: 'IOTX',
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethRequiredMethods,
          chains: ['eip155:4689'],
          events: EthUtil.ethEvents,
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethOptionalMethods,
          chains: ['eip155:4689'],
          events: [],
        ),
      },
      rpcUrl: 'https://rpc.ankr.com/iotex',
    ),
    '1088': W3MChainInfo(
      chainName: 'Metis',
      namespace: 'eip155:1088',
      chainId: '1088',
      chainIcon: '3897a66d-40b9-4833-162f-a2c90531c900',
      tokenName: 'METIS',
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethRequiredMethods,
          chains: ['eip155:1088'],
          events: EthUtil.ethEvents,
        ),
      },
      optionalNamespaces: {
        'eip155': const RequiredNamespace(
          methods: EthUtil.ethOptionalMethods,
          chains: ['eip155:1088'],
          events: [],
        ),
      },
      rpcUrl: 'https://metis-mainnet.public.blastapi.io',
    ),
    // '1284': W3MChainInfo(
    //   chainName: 'Moonbeam',
    //   chainId: '1284',
    //   chainIcon: '161038da-44ae-4ec7-1208-0ea569454b00',
    //   tokenName: 'ETH',
    // ),
    // '1285': W3MChainInfo(
    //   chainName: 'Moonriver',
    //   chainId: '1285',
    //   chainIcon: 'f1d73bb6-5450-4e18-38f7-fb6484264a00',
    //   tokenName: 'ETH',
    // ),
  };

  static const Map<String, W3MAssetIcon> tokenPresets = {
    'ETH': W3MAssetIcon('692ed6ba-e569-459a-556a-776476829e00'),
    'WETH': W3MAssetIcon('692ed6ba-e569-459a-556a-776476829e00'),
    'AVAX': W3MAssetIcon('30c46e53-e989-45fb-4549-be3bd4eb3b00'),
    'FTM': W3MAssetIcon('06b26297-fe0c-4733-5d6b-ffa5498aac00'),
    'BNB': W3MAssetIcon('93564157-2e8e-4ce7-81df-b264dbee9b00'),
    'MATIC': W3MAssetIcon('41d04d42-da3b-4453-8506-668cc0727900'),
    'OP': W3MAssetIcon('ab9c186a-c52f-464b-2906-ca59d760a400'),
    'xDAI': W3MAssetIcon('02b53f6a-e3d4-479e-1cb4-21178987d100'),
    'EVMOS': W3MAssetIcon('f926ff41-260d-4028-635e-91913fc28e00'),
    'METIS': W3MAssetIcon('3897a66d-40b9-4833-162f-a2c90531c900'),
    'IOTX': W3MAssetIcon('34e68754-e536-40da-c153-6ef2e7188a00'),
  };
}
