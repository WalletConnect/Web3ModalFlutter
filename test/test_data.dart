import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_modal_flutter/models/listings.dart';
import 'package:walletconnect_modal_flutter/widgets/grid_list/grid_list_item_model.dart';
import 'package:web3modal_flutter/utils/eth_util.dart';

final List<Listing> testListings1 = [
  const Listing(
    id: '1',
    name: 'Test1',
    homepage: 'https://test1.com',
    imageId: 'test',
    app: App(),
    mobile: Redirect(
      universal: 'https://test1.com',
      native: 'https://test1.com',
    ),
    desktop: Redirect(),
  ),
  const Listing(
    id: '2',
    name: 'Test2',
    homepage: 'https://test2.com',
    imageId: 'test',
    app: App(),
    mobile: Redirect(
      universal: 'https://test2.com',
      native: 'https://test2.com',
    ),
    desktop: Redirect(),
  ),
];

final List<Listing> testListings2 = [
  const Listing(
    id: '1',
    name: 'Test1',
    homepage: 'https://test1.com',
    imageId: 'test',
    app: App(),
    mobile: Redirect(
      universal: 'https://test1.com',
      native: 'https://test1.com',
    ),
    desktop: Redirect(),
  ),
  const Listing(
    id: '2',
    name: 'Test2',
    homepage: 'https://test2.com',
    imageId: 'test',
    app: App(),
    mobile: Redirect(
      universal: 'https://test2.com',
      native: 'https://test2.com',
    ),
    desktop: Redirect(),
  ),
  const Listing(
    id: '3',
    name: 'Test3',
    homepage: 'https://test3.com',
    imageId: 'test',
    app: App(),
    mobile: Redirect(
      universal: 'https://test3.com',
      native: 'https://test3.com',
    ),
    desktop: Redirect(),
  ),
  const Listing(
    id: '4',
    name: 'Test4',
    homepage: 'https://test4.com',
    imageId: 'test',
    app: App(),
    mobile: Redirect(
      universal: 'https://test4.com',
      native: 'https://test4.com',
    ),
    desktop: Redirect(),
  ),
  const Listing(
    id: '5',
    name: 'Test5',
    homepage: 'https://test5.com',
    imageId: 'test',
    app: App(),
    mobile: Redirect(
      universal: 'https://test5.com',
      native: 'https://test5.com',
    ),
    desktop: Redirect(),
  ),
];

final List<GridListItemModel<WalletData>> itemList = testListings2.map((e) {
  return GridListItemModel<WalletData>(
    image: e.imageId,
    id: e.id,
    title: e.name,
    data: WalletData(
      listing: e,
      installed: false,
    ),
  );
}).toList();

final ListingResponse testResponse1 = ListingResponse(
  listings: Map.fromIterable(
    testListings1,
    key: (e) => e.id,
  ),
  total: testListings1.length,
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
        EthUtil.walletAddEthChain,
        EthUtil.walletSwitchEthChain,
      ],
      events: [],
    ),
  },
  self: connectionMetadata,
  peer: connectionMetadata,
);
