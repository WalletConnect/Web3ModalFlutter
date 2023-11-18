import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/services/explorer_service/models/api_response.dart';

final List<Listing> testListings1 = [
  Listing(
    id: '1',
    name: 'Test1',
    homepage: 'https://test1.com',
    imageId: 'test',
    // app: App(),
    // mobile: Redirect(
    //   universal: 'https://test1.com',
    //   native: 'https://test1.com',
    // ),
    // desktop: Redirect(),
    order: 1,
  ),
  Listing(
    id: '2',
    name: 'Test2',
    homepage: 'https://test2.com',
    imageId: 'test',
    // app: App(),
    // mobile: Redirect(
    //   universal: 'https://test2.com',
    //   native: 'https://test2.com',
    // ),
    // desktop: Redirect(),
    order: 2,
  ),
];

final List<Listing> testListings2 = [
  Listing(
    id: '1',
    name: 'Test1',
    homepage: 'https://test1.com',
    imageId: 'test',
    // app: App(),
    // mobile: Redirect(
    //   universal: 'https://test1.com',
    //   native: 'https://test1.com',
    // ),
    // desktop: Redirect(),
    order: 3,
  ),
  Listing(
    id: '2',
    name: 'Test2',
    homepage: 'https://test2.com',
    imageId: 'test',
    // app: App(),
    // mobile: Redirect(
    //   universal: 'https://test2.com',
    //   native: 'https://test2.com',
    // ),
    // desktop: Redirect(),
    order: 4,
  ),
  Listing(
    id: '3',
    name: 'Test3',
    homepage: 'https://test3.com',
    imageId: 'test',
    // app: App(),
    // mobile: Redirect(
    //   universal: 'https://test3.com',
    //   native: 'https://test3.com',
    // ),
    // desktop: Redirect(),
    order: 5,
  ),
  Listing(
    id: '4',
    name: 'Test4',
    homepage: 'https://test4.com',
    imageId: 'test',
    // app: App(),
    // mobile: Redirect(
    //   universal: 'https://test4.com',
    //   native: 'https://test4.com',
    // ),
    // desktop: Redirect(),
    order: 6,
  ),
  Listing(
    id: '5',
    name: 'Test5',
    homepage: 'https://test5.com',
    imageId: 'test',
    // app: App(),
    // mobile: Redirect(
    //   universal: 'https://test5.com',
    //   native: 'https://test5.com',
    // ),
    // desktop: Redirect(),
    order: 7,
  ),
];

final itemList = testListings2.map((e) {
  return W3MWalletInfo(
    listing: e,
    installed: false,
    recent: false,
  );
}).toList();

final testResponse1 = ApiResponse<Listing>(
  data: testListings1,
  count: testListings1.length,
);

const metadata = PairingMetadata(
  name: 'Flutter WalletConnect',
  description: 'Flutter Web3Modal Sign Example',
  url: 'https://walletconnect.com/',
  icons: ['https://walletconnect.com/walletconnect-logo.png'],
);

const connectionMetadata = ConnectionMetadata(
  publicKey: '0xabc',
  metadata: metadata,
);

final testSession = SessionData(
  topic: 'a',
  pairingTopic: 'b',
  relay: Relay('irn'),
  expiry: 1,
  acknowledged: true,
  controller: 'test',
  namespaces: {
    'test': const Namespace(
      accounts: ['eip155:1:0x123'],
      methods: [
        'method1',
      ],
      events: [],
    ),
  },
  self: connectionMetadata,
  peer: connectionMetadata,
);

final testSessionWalletSwap = SessionData(
  topic: 'a',
  pairingTopic: 'b',
  relay: Relay('irn'),
  expiry: 1,
  acknowledged: true,
  controller: 'test',
  namespaces: {
    'test': const Namespace(
      accounts: ['eip155:1:0x123'],
      methods: [
        'method1',
        EthConstants.walletAddEthChain,
        EthConstants.walletSwitchEthChain,
      ],
      events: [],
    ),
  },
  self: connectionMetadata,
  peer: connectionMetadata,
);
