import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';

import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/grid_item_modal.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/i_explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/models/api_response.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/utils/w3m_logger.dart';

import 'package:walletconnect_modal_flutter/services/utils/platform/i_platform_utils.dart';
import 'package:walletconnect_modal_flutter/services/utils/platform/platform_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/url/url_utils_singleton.dart';

class ExplorerService implements IExplorerService {
  static const _apiUrl = 'https://api.web3modal.com';

  final http.Client _client;
  final String _referer;
  String _recentWalletId = '';
  List<Listing> _listings = [];

  var _requestParams = const RequestParams(page: 1, entries: 100);

  List<GridItem<W3MWalletInfo>> _gridItems = [];
  List<GridItem<W3MWalletInfo>> _bkpGridItems = [];

  @override
  final String projectId;

  @override
  Set<String>? recommendedWalletIds;

  @override
  Set<String>? includedWalletIds;
  // String? _includedWalletsParam;

  @override
  Set<String>? excludedWalletIds;
  // String? _excludedWalletsParam;

  @override
  ValueNotifier<List<GridItem<W3MWalletInfo>>> itemList = ValueNotifier([]);

  @override
  ValueNotifier<bool> initialized = ValueNotifier(false);

  ExplorerService({
    required this.projectId,
    required String referer,
    this.recommendedWalletIds,
    this.includedWalletIds,
    this.excludedWalletIds,
  })  : _referer = referer,
        _client = http.Client();

  @override
  Future<void> init() async {
    if (initialized.value) {
      return;
    }

    final includedWalletsParam = (includedWalletIds ?? <String>{}).isNotEmpty
        ? includedWalletIds!.toList().join(',')
        : null;
    final excludedWalletsParam = (excludedWalletIds ?? <String>{}).isNotEmpty
        ? excludedWalletIds!.toList().join(',')
        : null;

    _requestParams = _requestParams.copyWith(
      include: includedWalletsParam,
      exclude: excludedWalletsParam,
      platform: _getPlatformType(),
    );

    _listings = await _fetchListings(params: _requestParams);
    _listings = _listings.sortByRecommended(recommendedWalletIds);

    // Get the recent wallet
    final recentId = storageService.instance.getString(
      StringConstants.recentWallet,
    );
    _recentWalletId = recentId ?? '';

    _gridItems = await _gridItemsWithList(_listings);

    updateRecentPosition(_recentWalletId);
    initialized.value = true;
    W3MLoggerUtil.logger.i('ExplorerService initialized');
  }

  @override
  String getWalletImageUrl(String imageId) =>
      '$_apiUrl/getWalletImage/$imageId';

  @override
  String getAssetImageUrl(String imageId) =>
      '$_apiUrl/public/getAssetImage/$imageId';

  @override
  Redirect? getRedirect({required String name}) {
    //   try {
    //     W3MLoggerUtil.logger.i('Getting redirect for $name');
    //     final Listing listing = _listings.firstWhere(
    //       (listing) => listing.name.contains(name) || name.contains(listing.name),
    //     );

    //     return listing.mobile;
    //   } catch (e) {
    //     return null;
    //   }
    throw UnimplementedError();
  }

  Future<List<Listing>> _fetchListings({RequestParams? params}) async {
    try {
      final headers = coreUtils.instance.getAPIHeaders(projectId, _referer);
      debugPrint(headers.toString());
      final uri = Uri.parse('$_apiUrl/getWallets');
      W3MLoggerUtil.logger.i('Fetching wallet listings. Headers: $headers');
      W3MLoggerUtil.logger.i('Fetching wallet listings. Params: $params');
      W3MLoggerUtil.logger.i('Fetching wallet listings. Uri: $uri');
      final response = await _client.get(
        uri.replace(queryParameters: params?.toJson() ?? {}),
        headers: headers,
      );
      final apiResponse = ApiResponse.fromJson(jsonDecode(response.body));
      return apiResponse.data.toList();
    } catch (e, s) {
      W3MLoggerUtil.logger.e('Error retching wallet listings', e, s);
      throw Exception(e);
    }
  }

  @override
  void updateRecentPosition(String recentId) {
    final currentList = itemList.value.isNotEmpty ? itemList.value : _gridItems;
    final wallets = List<GridItem<W3MWalletInfo>>.from(
      currentList
          .map((e) => e.copyWith(data: e.data.copyWith(recent: false)))
          .toList(),
    );
    final recentWallet = wallets.firstWhereOrNull((e) => e.id == recentId);
    if (recentWallet != null) {
      final rw = recentWallet.copyWith(
        data: recentWallet.data.copyWith(recent: true),
      );
      wallets.removeWhere((e) => e.id == rw.id);
      wallets.insert(0, rw);
    }
    _gridItems = List<GridItem<W3MWalletInfo>>.from(wallets);
    _bkpGridItems = List<GridItem<W3MWalletInfo>>.from(wallets);
    itemList.value = _gridItems;
  }

  @override
  void filterList({String? query}) async {
    if (query == null || query.isEmpty) {
      itemList.value = _bkpGridItems;
      return;
    }

    debugPrint('filterList $query');
    final filtered = _bkpGridItems
        .where((wallet) =>
            wallet.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    itemList.value = filtered;

    await _searchListings(query: query);
  }

  Future<void> _searchListings({String? query}) async {
    final exclude = itemList.value.map((e) => e.id).toList().join(',');
    final results = await _fetchListings(
      params: _requestParams.copyWith(
        page: 1,
        search: query,
        exclude: exclude,
      ),
    );

    // final sortedByRecommended = _sortByRecommended(results);
    final newGridItems = await _gridItemsWithList(results);
    itemList.value = [...itemList.value, ...newGridItems];
  }

  Future<List<GridItem<W3MWalletInfo>>> _gridItemsWithList(
      List<Listing> list) async {
    List<GridItem<W3MWalletInfo>> gridItems = [];
    for (Listing item in list) {
      final appScheme = item.mobileLink;
      // // If we are on android, and we have an android link, get the package id and use that
      // if (Platform.isAndroid && item.app.android != null) {
      //   uri = getAndroidPackageId(item.app.android);
      // }
      bool installed = await urlUtils.instance.isInstalled(appScheme);
      bool recent = _recentWalletId == item.id;

      // TODO this logic doesn't belong here, this is UI logic, not business logic
      gridItems.add(
        GridItem<W3MWalletInfo>(
          title: item.name,
          id: item.id,
          image: getWalletImageUrl(item.imageId),
          data: W3MWalletInfo(
            listing: item,
            installed: installed,
            recent: recent,
          ),
        ),
      );
    }
    return gridItems;
  }

  // final Map<String, String> _storedAndroidPackageIds = {};

  // String? getAndroidPackageId(String? playstoreLink) {
  //   if (playstoreLink == null) {
  //     return null;
  //   }

  //   // If we have stored the package id, return it
  //   if (_storedAndroidPackageIds.containsKey(playstoreLink)) {
  //     return _storedAndroidPackageIds[playstoreLink];
  //   }

  //   final Uri playstore = Uri.parse(playstoreLink);
  //   W3MLoggerUtil.logger.i(
  //     'getAndroidPackageId: $playstoreLink, id: ${playstore.queryParameters['id']}',
  //   );

  //   _storedAndroidPackageIds[playstoreLink] =
  //       playstore.queryParameters['id'] ?? '';

  //   return playstore.queryParameters['id'];
  // }

  String _getPlatformType() {
    final type = platformUtils.instance.getPlatformType();
    final platform = type.toString().toLowerCase();
    switch (type) {
      case PlatformType.mobile:
        if (Platform.isIOS) {
          return 'ios';
        } else if (Platform.isAndroid) {
          return 'android';
        } else {
          return 'mobile';
        }
      default:
        return platform;
    }
  }
}

extension on List<Listing> {
  List<Listing> sortByRecommended(Set<String>? recommendedWalletIds) {
    List<Listing> sortedByRecommended = [];
    Set<String> recommendedIds = recommendedWalletIds ?? <String>{};
    List<Listing> listToSort = this;

    if (recommendedIds.isNotEmpty) {
      for (var recommendedId in recommendedWalletIds!) {
        final rw = listToSort.firstWhereOrNull(
          (element) => element.id == recommendedId,
        );
        if (rw != null) {
          sortedByRecommended.add(rw);
          listToSort.removeWhere((element) => element.id == recommendedId);
        }
      }
      sortedByRecommended.addAll(listToSort);
      return sortedByRecommended;
    }
    return listToSort;
  }
}
