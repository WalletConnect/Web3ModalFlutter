import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';
import 'package:web3modal_flutter/utils/url/url_utils_singleton.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/models/w3m_wallet_info.dart';
import 'package:web3modal_flutter/services/explorer_service/i_explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/models/api_response.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/utils/w3m_logger.dart';
import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/utils/platform/platform_utils_singleton.dart';

const int _defaultEntriesCount = 48;

class ExplorerService implements IExplorerService {
  static const _apiUrl = 'https://api.web3modal.com';

  final http.Client _client;
  final String _referer;

  late RequestParams _requestParams;

  String _recentWalletId = '';
  @override
  String get recentWalletId => _recentWalletId;

  @override
  final String projectId;

  @override
  ValueNotifier<int> totalListings = ValueNotifier(0);

  @override
  ValueNotifier<List<W3MWalletInfo>> listings = ValueNotifier([]);
  List<W3MWalletInfo> _listings = [];

  Set<String> _installedWalletIds = <String>{};

  @override
  Set<String>? featuredWalletIds;

  @override
  Set<String>? includedWalletIds;

  String? get _includedWalletsParam {
    final includedIds = includedWalletIds = (includedWalletIds ?? <String>{})
      ..removeAll(_installedWalletIds);
    return includedIds.isNotEmpty ? includedIds.join(',') : null;
  }

  @override
  Set<String>? excludedWalletIds;

  String? get _excludedWalletsParam {
    final excludedIds = (excludedWalletIds ?? <String>{})
      ..addAll(_installedWalletIds);
    return excludedIds.isNotEmpty ? excludedIds.join(',') : null;
  }

  @override
  ValueNotifier<bool> initialized = ValueNotifier(false);

  ExplorerService({
    required this.projectId,
    required String referer,
    this.featuredWalletIds,
    this.includedWalletIds,
    this.excludedWalletIds,
  })  : _referer = referer,
        _client = http.Client();

  @override
  Future<void> init() async {
    if (initialized.value) {
      return;
    }

    W3MLoggerUtil.logger.t('[$runtimeType] init()');

    await _getInstalledWalletIds();

    initialized.value = true;
    W3MLoggerUtil.logger.t('[$runtimeType] init() done');
  }

  Future<void> _getInstalledWalletIds() async {
    final installed = await (await _fetchNativeAppData()).getInstalledApps();
    _installedWalletIds = Set<String>.from(installed.map((e) => e.id));
  }

  Future<void> _getRecentWalletAndOrder() async {
    final recentWalletId =
        storageService.instance.getString(StringConstants.recentWallet);
    await updateRecentPosition(recentWalletId);
  }

  @override
  Future<void> fetchInitialWallets() async {
    totalListings.value = 0;
    final allListings = await Future.wait([
      _fetchInstalledListings(),
      _fetchOtherListings(firstCall: true),
    ]);

    _listings = [...allListings.first, ...allListings.last];
    listings.value = _listings;
    W3MLoggerUtil.logger
        .t('[$runtimeType] fetchInitialWallets ${_listings.length}');
    await _getRecentWalletAndOrder();
  }

  @override
  Future<void> paginate() async {
    final newParams = _requestParams.nextPage();
    final totalCount = totalListings.value;
    if (newParams.page * newParams.entries > totalCount) return;

    int entries = _defaultEntriesCount - _listings.length;
    if (entries <= 0) {
      _requestParams = newParams.copyWith(entries: _defaultEntriesCount);
    } else {
      final exclude = _listings.map((e) => e.listing.id).toList().join(',');
      _requestParams = newParams.copyWith(
        entries: entries,
        page: 1,
        exclude: exclude,
      );
    }
    W3MLoggerUtil.logger
        .t('[$runtimeType] paginate ${_requestParams.toJson()}');
    final newListings = await _fetchListings(
      params: _requestParams,
      updateCount: false,
    );

    _listings = [..._listings, ...newListings];
    listings.value = _listings;
  }

  @override
  String getWalletImageUrl(String imageId) =>
      '$_apiUrl/getWalletImage/$imageId';

  @override
  String getAssetImageUrl(String imageId) {
    if (imageId.contains('http')) {
      return imageId;
    }
    return '$_apiUrl/public/getAssetImage/$imageId';
  }

  @override
  WalletRedirect? getWalletRedirectByName(Listing listing) {
    final wallet = listings.value.firstWhereOrNull(
      (item) => listing.id == item.listing.id,
    );
    if (wallet == null) {
      return null;
    }
    return WalletRedirect(
      mobile: wallet.listing.mobileLink,
      desktop: wallet.listing.desktopLink,
      web: wallet.listing.webappLink,
    );
  }

  Future<List<NativeAppData>> _fetchNativeAppData() async {
    try {
      final headers = coreUtils.instance.getAPIHeaders(projectId, _referer);
      final uri = Platform.isIOS
          ? Uri.parse('$_apiUrl/getIosData')
          : Uri.parse('$_apiUrl/getAndroidData');
      final response = await _client.get(uri, headers: headers);
      final apiResponse = ApiResponse<NativeAppData>.fromJson(
        jsonDecode(response.body),
        (json) => NativeAppData.fromJson(json),
      );
      return apiResponse.data.toList();
    } catch (e, s) {
      W3MLoggerUtil.logger.e(
        '[$runtimeType] Error fetching native apps data',
        error: e,
        stackTrace: s,
      );
      throw Exception(e);
    }
  }

  Future<List<W3MWalletInfo>> _fetchInstalledListings() async {
    final pType = platformUtils.instance.getPlatformType();
    if (pType != PlatformType.mobile) {
      return [];
    }
    if (_installedWalletIds.isEmpty) {
      return [];
    }

    // I query with include set as my installed wallets
    final params = RequestParams(
      page: 1,
      entries: _installedWalletIds.length,
      include: _installedWalletIds.join(','),
    );
    // this query gives me a count of installedWalletsParam.length
    return (await _fetchListings(params: params)).setInstalledFlag();
  }

  Future<List<W3MWalletInfo>> _fetchOtherListings({
    bool firstCall = false,
  }) async {
    final installedCount = _installedWalletIds.length;
    final includedCount = _includedWalletsParam?.length ?? 0;
    final toQuery = 20 - installedCount + includedCount;
    final entriesCount = firstCall ? max(toQuery, 16) : _defaultEntriesCount;
    _requestParams = RequestParams(
      page: 1,
      entries: entriesCount,
      include: _includedWalletsParam,
      exclude: _excludedWalletsParam,
      platform: _getPlatformType(),
    );
    return await _fetchListings(params: _requestParams);
  }

  Future<List<W3MWalletInfo>> _fetchListings({
    RequestParams? params,
    bool updateCount = true,
  }) async {
    try {
      final headers = coreUtils.instance.getAPIHeaders(projectId, _referer);
      final uri = Uri.parse('$_apiUrl/getWallets');
      final response = await _client.get(
        uri.replace(queryParameters: params?.toJson() ?? {}),
        headers: headers,
      );
      final apiResponse = ApiResponse<Listing>.fromJson(
        jsonDecode(response.body),
        (json) => Listing.fromJson(json),
      );
      if (updateCount) {
        totalListings.value += apiResponse.count;
      }
      W3MLoggerUtil.logger
          .t('[$runtimeType] _fetchListings() $uri ${params?.toJson()}');
      return apiResponse.data
          .toList()
          .sortByRecommended(featuredWalletIds)
          .toW3MWalletInfo();
    } catch (e, s) {
      W3MLoggerUtil.logger.e(
        '[$runtimeType] Error fetching wallet listings',
        error: e,
        stackTrace: s,
      );
      throw Exception(e);
    }
  }

  @override
  Future<void> updateRecentPosition(String? recentId) async {
    _recentWalletId = recentId ?? '';
    // Set the recent
    await storageService.instance.setString(
      StringConstants.recentWallet,
      _recentWalletId,
    );
    final currentListings = List<W3MWalletInfo>.from(
      _listings.map((e) => e.copyWith(recent: false)).toList(),
    );
    final recentWallet = currentListings.firstWhereOrNull(
      (e) => e.listing.id == _recentWalletId,
    );
    if (recentWallet != null) {
      final rw = recentWallet.copyWith(recent: true);
      currentListings.removeWhere((e) => e.listing.id == rw.listing.id);
      currentListings.insert(0, rw);
    }
    _listings = currentListings;
    listings.value = _listings;
    W3MLoggerUtil.logger.t('[$runtimeType] updateRecentPosition($recentId)');
  }

  @override
  void search({String? query}) async {
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

    W3MLoggerUtil.logger.t('[$runtimeType] search $q');
    await _searchListings(query: q);
  }

  Future<void> _searchListings({String? query}) async {
    final exclude = _listings.map((e) => e.listing.id).toList().join(',');
    final newListins = await _fetchListings(
      params: _requestParams.copyWith(
        page: 1,
        search: query,
        exclude: exclude,
      ),
      updateCount: false,
    );

    listings.value = [...listings.value, ...newListins];
    W3MLoggerUtil.logger.t('[$runtimeType] _searchListings $query');
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
}

extension on List<Listing> {
  List<Listing> sortByRecommended(Set<String>? featuredWalletIds) {
    List<Listing> sortedByRecommended = [];
    Set<String> recommendedIds = featuredWalletIds ?? <String>{};
    List<Listing> listToSort = this;

    if (recommendedIds.isNotEmpty) {
      for (var recommendedId in featuredWalletIds!) {
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

extension on List<W3MWalletInfo> {
  List<W3MWalletInfo> setInstalledFlag() {
    return map((e) => e.copyWith(installed: true)).toList();
  }
}

extension on List<NativeAppData> {
  Future<List<NativeAppData>> getInstalledApps() async {
    final List<NativeAppData> installedApps = [];
    for (var appData in this) {
      bool installed = await urlUtils.instance.isInstalled(appData.schema);
      if (installed) {
        installedApps.add(appData);
      }
    }
    return installedApps;
  }
}
