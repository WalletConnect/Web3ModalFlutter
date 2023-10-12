import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';

import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/i_explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/models/api_response.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/utils/w3m_logger.dart';

import 'package:walletconnect_modal_flutter/services/utils/platform/i_platform_utils.dart';
import 'package:walletconnect_modal_flutter/services/utils/platform/platform_utils_singleton.dart';

class ExplorerService implements IExplorerService {
  static const _apiUrl = 'https://api.web3modal.com';

  final http.Client _client;
  final String _referer;

  late RequestParams _requestParams;

  @override
  final String projectId;

  @override
  ValueNotifier<int> totalListings = ValueNotifier(0);

  @override
  ValueNotifier<List<W3MWalletInfo>> listings = ValueNotifier([]);
  List<W3MWalletInfo> _listings = [];

  @override
  Set<String>? recommendedWalletIds;

  @override
  Set<String>? includedWalletIds;

  @override
  Set<String>? excludedWalletIds;

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

    _requestParams = RequestParams(
      page: 1,
      entries: 48,
      include: includedWalletsParam,
      exclude: excludedWalletsParam,
      platform: _getPlatformType(),
    );

    final fetchResults = await _fetchListings(params: _requestParams);
    _listings =
        fetchResults.sortByRecommended(recommendedWalletIds).toW3MWalletInfo();
    listings.value = _listings;

    // Get the recent wallet
    final recentWalletId = storageService.instance.getString(
          StringConstants.recentWallet,
        ) ??
        '';

    updateRecentPosition(recentWalletId);
    initialized.value = true;
    W3MLoggerUtil.logger.v('$runtimeType init() done');
  }

  @override
  Future<void> paginate() async {
    final newParams = _requestParams.nextPage();
    final totalCount = totalListings.value;
    if (newParams.page * newParams.entries > totalCount) return;

    _requestParams = newParams;
    final newPageResults = await _fetchListings(params: _requestParams);
    final newListings = newPageResults.toW3MWalletInfo();
    _listings = [..._listings, ...newListings];
    listings.value = _listings;
    W3MLoggerUtil.logger.v('$runtimeType paginate() ${newParams.toJson()}');
  }

  @override
  String getWalletImageUrl(String imageId) =>
      '$_apiUrl/getWalletImage/$imageId';

  @override
  String getAssetImageUrl(String imageId) =>
      '$_apiUrl/public/getAssetImage/$imageId';

  @override
  String? getRedirect({required String name}) {
    try {
      final wallet = _listings.firstWhere(
        (l) => l.listing.name.contains(name) || name.contains(l.listing.name),
      );
      W3MLoggerUtil.logger
          .v('Getting redirect for $name: ${wallet.listing.mobileLink}');
      return wallet.listing.mobileLink;
    } catch (e) {
      return null;
    }
  }

  Future<List<Listing>> _fetchListings({RequestParams? params}) async {
    try {
      final headers = coreUtils.instance.getAPIHeaders(projectId, _referer);
      final uri = Uri.parse('$_apiUrl/getWallets');
      final response = await _client.get(
        uri.replace(queryParameters: params?.toJson() ?? {}),
        headers: headers,
      );
      final apiResponse = ApiResponse.fromJson(jsonDecode(response.body));
      if ((params?.search ?? '').isEmpty) {
        totalListings.value = apiResponse.count;
      }
      W3MLoggerUtil.logger
          .v('$runtimeType _fetchListings() $uri ${params?.toJson()}');
      return apiResponse.data.toList();
    } catch (e, s) {
      W3MLoggerUtil.logger.e('Error retching wallet listings', e, s);
      throw Exception(e);
    }
  }

  @override
  void updateRecentPosition(String recentId) {
    final currentListings = List<W3MWalletInfo>.from(
      _listings.map((e) => e.copyWith(recent: false)).toList(),
    );
    final recentWallet = currentListings.firstWhereOrNull(
      (e) => e.listing.id == recentId,
    );
    if (recentWallet != null) {
      final rw = recentWallet.copyWith(recent: true);
      currentListings.removeWhere((e) => e.listing.id == rw.listing.id);
      currentListings.insert(0, rw);
    }
    _listings = currentListings;
    listings.value = _listings;
    W3MLoggerUtil.logger.v('$runtimeType updateRecentPosition($recentId)');
  }

  @override
  void filterList({String? query}) async {
    if (query == null || query.isEmpty) {
      listings.value = _listings;
      return;
    }

    final q = query.toLowerCase();
    final filtered = _listings.where((w) {
      final name = w.listing.name.toLowerCase();
      return name.contains(q);
    }).toList();
    listings.value = filtered;

    W3MLoggerUtil.logger.v('$runtimeType filterList($q)');
    await _searchListings(query: q);
  }

  Future<void> _searchListings({String? query}) async {
    final exclude = listings.value.map((e) => e.listing.id).toList().join(',');
    final fetchResults = await _fetchListings(
      params: _requestParams.copyWith(
        page: 1,
        search: query,
        exclude: exclude,
      ),
    );
    final newListins =
        fetchResults.sortByRecommended(recommendedWalletIds).toW3MWalletInfo();
    listings.value = [...listings.value, ...newListins];
    W3MLoggerUtil.logger.v('$runtimeType _searchListings($query)');
  }

  final Map<String, String> _storedAndroidPackageIds = {};

  @override
  String? getAndroidPackageId(String? playstoreLink) {
    if (playstoreLink == null) {
      return null;
    }

    // If we have stored the package id, return it
    if (_storedAndroidPackageIds.containsKey(playstoreLink)) {
      return _storedAndroidPackageIds[playstoreLink];
    }

    final Uri playstore = Uri.parse(playstoreLink);
    W3MLoggerUtil.logger.v(
      'getAndroidPackageId: $playstoreLink, id: ${playstore.queryParameters['id']}',
    );

    _storedAndroidPackageIds[playstoreLink] =
        playstore.queryParameters['id'] ?? '';

    return playstore.queryParameters['id'];
  }

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

  // @override
  // Future<Uint8List> getAssetImage(String imageId) async {
  //   try {
  //     final headers = coreUtils.instance.getAPIHeaders(projectId, _referer);
  //     final imageUrl = getAssetImageUrl(imageId);
  //     final uri = Uri.parse(imageUrl);
  //     final response = await _client.get(uri, headers: headers);
  //     return response.bodyBytes;
  //   } catch (e, s) {
  //     W3MLoggerUtil.logger.e('Error retching wallet listings', e, s);
  //     throw Exception(e);
  //   }
  // }
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

  List<W3MWalletInfo> toW3MWalletInfo() {
    return map(
      (item) => W3MWalletInfo(
        listing: item,
        installed: false,
        recent: false,
      ),
    ).toList();
  }
}
