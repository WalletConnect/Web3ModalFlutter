import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/models/listings.dart';
import 'package:web3modal_flutter/services/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/services/utils/platform/platform_utils_singleton.dart';
import 'package:web3modal_flutter/services/utils/url/url_utils_singleton.dart';
import 'package:web3modal_flutter/walletconnect_modal_flutter.dart';

import 'explorer_test_data.dart';
import '../mock_classes.mocks.dart';

void main() {
  group('ExplorerService', () {
    final client = MockClient();
    final explorerService = ExplorerService(
      projectId: 'test',
      client: client,
    );

    urlUtils.instance = MockUrlUtils();
    platformUtils.instance = MockPlatformUtils();
    when(
      platformUtils.instance.getPlatformType(),
    ).thenReturn(PlatformType.mobile);

    test('Test Initialization', () async {
      // assuming some mock referer and params for the init function
      when(
        urlUtils.instance.isInstalled(
          test_listings_1[0].mobile.native,
        ),
      ).thenAnswer((_) async => true);
      when(
        urlUtils.instance.isInstalled(
          test_listings_1[1].mobile.native,
        ),
      ).thenAnswer((_) async => false);
      when(client.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          json.encode(test_response_1.toJson()),
          200,
        ),
      );
      String referer = 'test_referer';
      await explorerService.init(referer: referer);

      // add assertions based on your expected outcomes
      expect(
        explorerService.initialized.value,
        equals(true),
      );
      print(explorerService.itemList.value);
      expect(
        explorerService.itemList.value.length,
        equals(2),
      );
      expect(
        explorerService.itemList.value[0].data.listing.name,
        equals('Test1'),
      );
      expect(
        explorerService.itemList.value[0].data.installed,
        true,
      );
      expect(
        explorerService.itemList.value[1].data.listing.name,
        equals('Test2'),
      );
      expect(
        explorerService.itemList.value[1].data.installed,
        false,
      );
    });

    test('Test Fetching of Wallet Listings', () async {
      when(client.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          json.encode(test_response_1.toJson()),
          200,
        ),
      );
      final List<Listing> listings = await explorerService.fetchListings(
        endpoint: '/w3m/v1/getDesktopListings',
        referer: 'test_referer',
      );

      // add assertions based on your expected outcomes
      expect(
        listings.length,
        equals(2),
      );
      expect(
        listings[0].name,
        equals('Test1'),
      );
      expect(
        listings[1].name,
        equals('Test2'),
      );
    });

    test('Test Image URL Generation', () {
      String imageId = 'test_id';
      expect(
        explorerService.getWalletImageUrl(imageId: imageId),
        equals(
          'https://explorer-api.walletconnect.com/w3m/v1/getWalletImage/test_id?projectId=test',
        ),
      );
      expect(
        explorerService.getAssetImageUrl(imageId: imageId),
        equals(
          'https://explorer-api.walletconnect.com/w3m/v1/getAssetImage/test_id?projectId=test',
        ),
      );
    });

    test('Test Filter Functionality', () {
      explorerService.filterList(query: 'Test2');

      // add assertions based on your expected outcomes
      expect(
        explorerService.itemList.value.length,
        equals(1),
      );
      expect(
        explorerService.itemList.value[0].data.listing.name,
        equals('Test2'),
      );

      explorerService.filterList();
    });

    test('Test Redirect Fetching', () {
      Redirect? redirect = explorerService.getRedirect(name: 'blank');
      expect(redirect, null);

      redirect = explorerService.getRedirect(name: 'Test');
      expect(redirect != null, true);
      expect(redirect!.universal, equals('https://test1.com'));

      redirect = explorerService.getRedirect(name: 'Test2');
      expect(redirect != null, true);
      expect(redirect!.universal, equals('https://test2.com'));
    });

    test('Test Filtering of Excluded Listings', () {
      explorerService.excludedWalletIds = {'1'};
      var filteredListings = explorerService.filterExcludedListings(
        listings: test_listings_1,
      );

      expect(
        filteredListings,
        equals(
          [
            test_listings_1[1],
          ],
        ),
      );
    });
  });
}
