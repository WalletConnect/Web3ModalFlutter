import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web3modal_flutter/services/coinbase_service/coinbase_service.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';
import 'package:web3modal_flutter/services/explorer_service/models/wc_sample_wallets.dart';
import 'package:web3modal_flutter/utils/debouncer.dart';
import 'package:web3modal_flutter/utils/url/url_utils_singleton.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/explorer_service/i_explorer_service.dart';
import 'package:web3modal_flutter/services/explorer_service/models/api_response.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/utils/platform/platform_utils_singleton.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

const int _defaultEntriesCount = 48;

class ExplorerService implements IExplorerService {
  static const _apiUrl = 'https://api.web3modal.com';

  final http.Client _client;
  final String _referer;

  late RequestParams _requestParams;

  @override
  final String projectId;

  @override
  ValueNotifier<bool> initialized = ValueNotifier(false);

  @override
  ValueNotifier<int> totalListings = ValueNotifier(0);

  List<W3MWalletInfo> _listings = [];
  @override
  ValueNotifier<List<W3MWalletInfo>> listings = ValueNotifier([]);

  final _debouncer = Debouncer(milliseconds: 300);

  String? _currentSearchValue;
  @override
  String get searchValue => _currentSearchValue ?? '';

  @override
  ValueNotifier<bool> isSearching = ValueNotifier(false);

  @override
  Set<String>? includedWalletIds;
  String? get _includedWalletsParam {
    final includedIds = (includedWalletIds ?? <String>{});
    return includedIds.isNotEmpty ? includedIds.join(',') : null;
  }

  @override
  Set<String>? excludedWalletIds;
  String? get _excludedWalletsParam {
    final excludedIds = (excludedWalletIds ?? <String>{})
      ..addAll(_installedWalletIds)
      ..addAll(featuredWalletIds ?? {});
    return excludedIds.isNotEmpty ? excludedIds.join(',') : null;
  }

  @override
  Set<String>? featuredWalletIds;
  String? get _featuredWalletsParam {
    final featuredIds = Set.from(featuredWalletIds ?? {});
    featuredIds.removeWhere((e) => _installedWalletIds.contains(e));
    return featuredIds.isNotEmpty ? featuredIds.join(',') : null;
  }

  Set<String> _installedWalletIds = <String>{};
  String? get _installedWalletsParam {
    return _installedWalletIds.isNotEmpty
        ? _installedWalletIds.join(',')
        : null;
  }

  int _currentWalletsCount = 0;
  bool _canPaginate = true;
  @override
  bool get canPaginate => _canPaginate;

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

    await _setInstalledWalletIdsParam();
    await _fetchInitialWallets();

    initialized.value = true;
    W3MLoggerUtil.logger.t('[$runtimeType] init() done');
  }

  Future<void> _setInstalledWalletIdsParam() async {
    final nativeData = await _fetchNativeAppData();
    final installed = await nativeData.getInstalledApps();
    _installedWalletIds = Set<String>.from(installed.map((e) => e.id));
  }

  Future<void> _fetchInitialWallets() async {
    totalListings.value = 0;
    final allListings = await Future.wait([
      _loadWCSampleWallets(),
      _fetchInstalledListings(),
      _fetchFeaturedListings(),
      _fetchOtherListings(),
    ]);

    _listings = [
      ...allListings[0],
      ...allListings[1].sortByFeaturedIds(featuredWalletIds),
      ...allListings[2].sortByFeaturedIds(featuredWalletIds),
      ...allListings[3].sortByFeaturedIds(featuredWalletIds),
    ];
    listings.value = _listings;

    if (_listings.length < _defaultEntriesCount) {
      _canPaginate = false;
    }

    await _getRecentWalletAndOrder();
  }

  Future<List<W3MWalletInfo>> _loadWCSampleWallets() async {
    final platform = platformUtils.instance.getPlatformExact().name;
    final platformName = platform.toString().toLowerCase();
    List<W3MWalletInfo> sampleWallets = [];
    for (var sampleWallet in WCSampleWallets.getSampleWallets(platformName)) {
      final data = WCSampleWallets.nativeData[sampleWallet.listing.id];
      final schema = (data?[platformName]! as NativeAppData).schema ?? '';
      final installed = await urlUtils.instance.isInstalled(schema);
      if (installed) {
        sampleWallet = sampleWallet.copyWith(installed: true);
        sampleWallets.add(sampleWallet);
      }
    }
    return sampleWallets;
  }

  Future<void> _getRecentWalletAndOrder() async {
    W3MWalletInfo? walletInfo;
    final walletString = storageService.instance.getString(
      StringConstants.connectedWalletData,
      defaultValue: '',
    );
    if (walletString!.isNotEmpty) {
      walletInfo = W3MWalletInfo.fromJson(jsonDecode(walletString));
      if (!walletInfo.installed) {
        walletInfo = null;
      }
    }

    final walletId = storageService.instance.getString(
      StringConstants.recentWalletId,
    );
    await _updateRecentWalletId(walletInfo, walletId: walletId);
  }

  @override
  Future<void> paginate() async {
    if (!canPaginate) return;
    _requestParams = _requestParams.nextPage();
    final newListings = await _fetchListings(
      params: _requestParams,
      updateCount: false,
    );
    _listings = [..._listings, ...newListings];
    listings.value = _listings;
    if (newListings.length < _currentWalletsCount) {
      _canPaginate = false;
    } else {
      _currentWalletsCount = newListings.length;
    }
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
      include: _installedWalletsParam,
      platform: _getPlatformType(),
    );
    // this query gives me a count of installedWalletsParam.length
    return (await _fetchListings(params: params)).setInstalledFlag();
  }

  Future<List<W3MWalletInfo>> _fetchFeaturedListings() async {
    if ((_featuredWalletsParam ?? '').isEmpty) {
      return [];
    }
    final params = RequestParams(
      page: 1,
      entries: _featuredWalletsParam!.split(',').length,
      include: _featuredWalletsParam,
      platform: _getPlatformType(),
    );
    return await _fetchListings(params: params);
  }

  Future<List<W3MWalletInfo>> _fetchOtherListings() async {
    _requestParams = RequestParams(
      page: 1,
      entries: _defaultEntriesCount,
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
    final p = params?.toJson() ?? {};
    try {
      final headers = coreUtils.instance.getAPIHeaders(projectId, _referer);
      final uri = Uri.parse('$_apiUrl/getWallets').replace(queryParameters: p);
      final response = await _client.get(uri, headers: headers);
      final apiResponse = ApiResponse<Listing>.fromJson(
        jsonDecode(response.body),
        (json) => Listing.fromJson(json),
      );
      if (updateCount) {
        totalListings.value += apiResponse.count;
      }
      W3MLoggerUtil.logger.t('[$runtimeType] _fetchListings() $uri $p');
      return apiResponse.data.toList().toW3MWalletInfo();
    } catch (error) {
      W3MLoggerUtil.logger
          .e('[$runtimeType] Error fetch wallets params: $p', error: error);
      throw Exception(e);
    }
  }

  @override
  Future<void> storeConnectedWallet(W3MWalletInfo? walletInfo) async {
    if (walletInfo == null) return;
    final walletDataString = jsonEncode(walletInfo.toJson());
    await storageService.instance.setString(
      StringConstants.connectedWalletData,
      walletDataString,
    );
    await _updateRecentWalletId(walletInfo, walletId: walletInfo.listing.id);
  }

  @override
  Future<void> storeRecentWalletId(String? walletId) async {
    if (walletId == null) return;
    await storageService.instance.setString(
      StringConstants.recentWalletId,
      walletId,
    );
  }

  @override
  W3MWalletInfo? getConnectedWallet() {
    try {
      final walletString = storageService.instance.getString(
        StringConstants.connectedWalletData,
        defaultValue: '',
      );
      if (walletString!.isNotEmpty) {
        return W3MWalletInfo.fromJson(jsonDecode(walletString));
      }
    } catch (e, s) {
      W3MLoggerUtil.logger.e(
        '[$runtimeType] error getConnectedWallet:',
        error: e,
        stackTrace: s,
      );
    }
    return null;
  }

  Future<void> _updateRecentWalletId(
    W3MWalletInfo? walletInfo, {
    String? walletId,
  }) async {
    try {
      final recentId = walletInfo?.listing.id ?? walletId;
      await storeRecentWalletId(recentId);

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
      W3MLoggerUtil.logger.t('[$runtimeType] _updateRecentWalletId $walletId '
          '${walletInfo?.toJson()}');
    } catch (e, s) {
      W3MLoggerUtil.logger.e(
        '[$runtimeType] _updateRecentWalletId',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  void search({String? query}) async {
    if (query == null || query.isEmpty) {
      _currentSearchValue = null;
      listings.value = _listings;
      return;
    }

    final q = query.toLowerCase();
    await _searchListings(query: q);
  }

  Future<void> _searchListings({String? query}) async {
    isSearching.value = true;

    final includedIds = (includedWalletIds ?? <String>{});
    final include = includedIds.isNotEmpty ? includedIds.join(',') : null;
    final excludedIds = (excludedWalletIds ?? <String>{});
    final exclude = excludedIds.isNotEmpty ? excludedIds.join(',') : null;

    W3MLoggerUtil.logger.t('[$runtimeType] search $query');
    _currentSearchValue = query;
    final newListins = await _fetchListings(
      params: RequestParams(
        page: 1,
        entries: 100,
        search: _currentSearchValue,
        include: include,
        exclude: exclude,
        platform: _getPlatformType(),
      ),
      updateCount: false,
    );

    listings.value = newListins;
    W3MLoggerUtil.logger.t('[$runtimeType] _searchListings $query');
    _debouncer.run(() => isSearching.value = false);
  }

  @override
  Future<W3MWalletInfo?> getCoinbaseWalletObject() async {
    final results = await _fetchListings(
      params: RequestParams(
        page: 1,
        entries: 1,
        search: 'coinbase wallet',
        // platform: _getPlatformType(),
      ),
      updateCount: false,
    );

    if (results.isNotEmpty) {
      final wallet = W3MWalletInfo.fromJson(results.first.toJson());
      bool installed = await urlUtils.instance.isInstalled(
        CoinbaseService.coinbaseSchema,
      );
      return wallet.copyWith(
        listing: wallet.listing.copyWith(
          mobileLink: CoinbaseService.coinbaseSchema,
        ),
        installed: installed,
      );
    }
    return null;
  }

  @override
  String getWalletImageUrl(String imageId) {
    if (imageId.startsWith('http')) {
      return imageId;
    }
    return '$_apiUrl/getWalletImage/$imageId';
  }

  @override
  String getAssetImageUrl(String imageId) {
    if (imageId.startsWith('http')) {
      return imageId;
    }
    return '$_apiUrl/public/getAssetImage/$imageId';
  }

  @override
  WalletRedirect? getWalletRedirect(W3MWalletInfo? walletInfo) {
    if (walletInfo == null) return null;
    if (walletInfo.listing.id == CoinbaseService.coinbaseWalletId) {
      return WalletRedirect(
        mobile: CoinbaseService.coinbaseSchema,
        desktop: null,
        web: null,
      );
    }
    return WalletRedirect(
      mobile: walletInfo.listing.mobileLink?.trim(),
      desktop: walletInfo.listing.desktopLink,
      web: walletInfo.listing.webappLink,
    );
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
  List<W3MWalletInfo> sortByFeaturedIds(Set<String>? featuredWalletIds) {
    Map<String, dynamic> sortedMap = {};
    final auxList = List<W3MWalletInfo>.from(this);

    for (var id in featuredWalletIds ?? <String>{}) {
      final featured = auxList.firstWhereOrNull((e) => e.listing.id == id);
      if (featured != null) {
        auxList.removeWhere((e) => e.listing.id == id);
        sortedMap[id] = featured;
      }
    }

    return [...sortedMap.values, ...auxList];
  }

  List<W3MWalletInfo> setInstalledFlag() {
    return map((e) => e.copyWith(installed: true)).toList();
  }
}

extension on List<NativeAppData> {
  Future<List<NativeAppData>> getInstalledApps() async {
    final installedApps = <NativeAppData>[];
    for (var appData in this) {
      bool installed = await urlUtils.instance.isInstalled(appData.schema);
      if (installed) {
        installedApps.add(appData);
      }
    }
    return installedApps;
  }
}
