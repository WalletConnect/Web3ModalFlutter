import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/models/listings.dart';

final List<Listing> test_listings_1 = [
  Listing(
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
  Listing(
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

final ListingResponse test_response_1 = ListingResponse(
  listings: Map.fromIterable(
    test_listings_1,
    key: (e) => e.id,
  ),
  total: test_listings_1.length,
);
