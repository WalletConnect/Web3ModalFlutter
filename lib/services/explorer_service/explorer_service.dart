import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';

import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/grid_item_modal.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/i_explorer_service.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/utils/w3m_logger.dart';

import 'package:walletconnect_modal_flutter/services/utils/core/core_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/platform/i_platform_utils.dart';
import 'package:walletconnect_modal_flutter/services/utils/platform/platform_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/url/url_utils_singleton.dart';

class ExplorerService implements IExplorerService {
  @override
  final String explorerUriRoot;

  @override
  final String projectId;

  @override
  Set<String>? recommendedWalletIds;

  @override
  ExcludedWalletState excludedWalletState;

  @override
  Set<String>? excludedWalletIds;

  List<Listing> _listings = [];
  List<GridItem<W3MWalletInfo>> _walletListUnsorted = [];
  List<GridItem<W3MWalletInfo>> _walletListSorted = [];

  @override
  ValueNotifier<List<GridItem<W3MWalletInfo>>> itemList = ValueNotifier([]);

  @override
  ValueNotifier<bool> initialized = ValueNotifier(false);

  final http.Client client;

  final String referer;

  String? previousRecentWallet;

  ExplorerService({
    required this.projectId,
    required this.referer,
    this.explorerUriRoot = 'https://explorer-api.walletconnect.com',
    this.recommendedWalletIds,
    this.excludedWalletState = ExcludedWalletState.list,
    this.excludedWalletIds,
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<void> init() async {
    if (initialized.value) {
      return;
    }

    String? platform;
    switch (platformUtils.instance.getPlatformType()) {
      case PlatformType.desktop:
        platform = 'Desktop';
        break;
      case PlatformType.mobile:
        if (Platform.isIOS) {
          platform = 'iOS';
        } else if (Platform.isAndroid) {
          platform = 'Android';
        } else {
          platform = 'Mobile';
        }
        break;
      case PlatformType.web:
        platform = 'Injected';
        break;
      default:
        platform = null;
    }

    W3MLoggerUtil.logger.i('Fetching wallet listings. Platform: $platform');
    _listings = await fetchListings(
      endpoint: '/w3m/v1/get${platform}Listings',
      referer: referer,
      // params: params,
    );

    if (excludedWalletState == ExcludedWalletState.list) {
      // If we are excluding all wallets, take out the excluded listings, if they exist
      if (excludedWalletIds != null) {
        _listings = filterExcludedListings(
          listings: _listings,
        );
      }
    } else if (excludedWalletState == ExcludedWalletState.all &&
        recommendedWalletIds != null) {
      // Filter down to only the included
      _listings = _listings
          .where(
            (listing) => recommendedWalletIds!.contains(
              listing.id,
            ),
          )
          .toList();
    } else {
      // If we are excluding all wallets and have no recommended wallets,
      // return an empty list
      _walletListUnsorted = [];
      itemList.value = [];
      return;
    }

    // Get the recent wallet
    final String? recentWallet =
        storageService.instance.getString(StringConstants.recentWallet);
    previousRecentWallet = recentWallet;

    for (Listing item in _listings) {
      String? uri = item.mobile.native;
      // If we are on android, and we have an android link, get the package id and use that
      if (Platform.isAndroid && item.app.android != null) {
        uri = getAndroidPackageId(item.app.android);
      }
      bool installed = await urlUtils.instance.isInstalled(uri);
      bool recent = recentWallet == item.id;
      if (installed) {
        W3MLoggerUtil.logger.v('Wallet ${item.name} installed: $installed');
      }

      _walletListUnsorted.add(
        GridItem<W3MWalletInfo>(
          title: item.name,
          id: item.id,
          description: recent
              ? 'Recent'
              : installed
                  ? 'Installed'
                  : null,
          image: getWalletImageUrl(
            imageId: item.imageId,
          ),
          data: W3MWalletInfo(
            listing: item,
            installed: installed,
            recent: recent,
          ),
        ),
      );
    }

    updateSort();

    initialized.value = true;
    W3MLoggerUtil.logger.i('ExplorerService initialized');
  }

  @override
  void filterList({
    String? query,
  }) {
    if (query == null || query.isEmpty) {
      itemList.value = _walletListSorted;
      return;
    }

    final List<GridItem<W3MWalletInfo>> filtered = _walletListSorted
        .where(
          (wallet) => wallet.title.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    itemList.value = filtered;
  }

  @override
  void updateSort() async {
    final List<GridItem<W3MWalletInfo>> newList = [];

    final String? recentWallet =
        storageService.instance.getString(StringConstants.recentWallet);

    // Sort the installed wallets to the top
    int insertAt = 0;
    for (int i = 0; i < _walletListUnsorted.length; i++) {
      // If the recent wallet doesn't match the id, then set it to not recent
      if (_walletListUnsorted[i].data.recent == true &&
          recentWallet != previousRecentWallet) {
        _walletListUnsorted[i] = _walletListUnsorted[i].copyWith(
          description:
              _walletListUnsorted[i].data.installed ? 'Installed' : null,
          data: _walletListUnsorted[i].data.copyWith(
                recent: false,
              ),
        );
      }
      // If the recent wallet matches the id, then set it to recent
      else if (_walletListUnsorted[i].id == recentWallet) {
        _walletListUnsorted[i] = _walletListUnsorted[i].copyWith(
          description: 'Recent',
          data: _walletListUnsorted[i].data.copyWith(
                recent: true,
              ),
        );
      }

      // Handle sorting
      if (_walletListUnsorted[i].data.recent == true) {
        newList.insert(0, _walletListUnsorted[i]);
        insertAt++;
      } else if (_walletListUnsorted[i].data.installed) {
        newList.insert(insertAt, _walletListUnsorted[i]);
        insertAt++;
      } else if (recommendedWalletIds != null &&
          recommendedWalletIds!.contains(_walletListUnsorted[i].id)) {
        newList.insert(insertAt, _walletListUnsorted[i]);
      } else {
        newList.add(_walletListUnsorted[i]);
      }
    }

    previousRecentWallet = recentWallet;
    _walletListSorted = newList;
    itemList.value = newList;
  }

  @override
  String getWalletImageUrl({
    required String imageId,
  }) {
    return '$explorerUriRoot/w3m/v1/getWalletImage/$imageId?projectId=$projectId';
  }

  @override
  String getAssetImageUrl({
    required String imageId,
  }) {
    return '$explorerUriRoot/w3m/v1/getAssetImage/$imageId?projectId=$projectId';
  }

  @override
  Redirect? getRedirect({required String name}) {
    try {
      W3MLoggerUtil.logger.i('Getting redirect for $name');
      final Listing listing = _listings.firstWhere(
        (listing) => listing.name.contains(name) || name.contains(listing.name),
      );

      return listing.mobile;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Listing>> fetchListings({
    required String endpoint,
    required String referer,
    ListingParams? params,
  }) async {
    W3MLoggerUtil.logger.i('Fetching wallet listings. Endpoint: $endpoint');
    final Map<String, String> headers = {
      'user-agent': coreUtils.instance.getUserAgent(),
      'referer': referer,
    };
    W3MLoggerUtil.logger.i('Fetching wallet listings. Headers: $headers');
    final Uri uri = Uri.parse(explorerUriRoot + endpoint);
    final Map<String, dynamic> queryParameters = {
      'projectId': projectId,
      ...params == null ? {} : params.toJson(),
    };
    final http.Response response = await client.get(
      uri.replace(
        queryParameters: queryParameters,
      ),
      headers: headers,
    );
    // print(json.decode(response.body)['listings'].entries.first);
    ListingResponse res = ListingResponse.fromJson(json.decode(response.body));
    return res.listings.values.toList();
  }

  final Map<String, String> _storedAndroidPackageIds = {};

  String? getAndroidPackageId(String? playstoreLink) {
    if (playstoreLink == null) {
      return null;
    }

    // If we have stored the package id, return it
    if (_storedAndroidPackageIds.containsKey(playstoreLink)) {
      return _storedAndroidPackageIds[playstoreLink];
    }

    final Uri playstore = Uri.parse(playstoreLink);
    W3MLoggerUtil.logger.i(
      'getAndroidPackageId: $playstoreLink, id: ${playstore.queryParameters['id']}',
    );

    _storedAndroidPackageIds[playstoreLink] =
        playstore.queryParameters['id'] ?? '';

    return playstore.queryParameters['id'];
  }

  List<Listing> filterExcludedListings({
    required List<Listing> listings,
  }) {
    return listings.where((listing) {
      if (excludedWalletIds!.contains(
        listing.id,
      )) {
        W3MLoggerUtil.logger.i('Excluding wallet from list: $listing');
        return false;
      }

      return true;
    }).toList();
  }
}
