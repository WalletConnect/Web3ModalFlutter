import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web3modal_flutter/constants/url_constants.dart';
import 'package:web3modal_flutter/models/listing.dart';
import 'package:web3modal_flutter/services/coinbase_service/coinbase_service.dart';
import 'package:web3modal_flutter/services/explorer_service/models/native_app_data.dart';
import 'package:web3modal_flutter/services/explorer_service/models/redirect.dart';
import 'package:web3modal_flutter/services/explorer_service/models/request_params.dart';
import 'package:web3modal_flutter/services/explorer_service/models/wc_sample_wallets.dart';
import 'package:web3modal_flutter/services/logger_service/logger_service_singleton.dart';
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
  final http.Client _client;
  final String _referer;

  late RequestParams _requestParams;
  late final ICore _core;

  @override
  String get projectId => _core.projectId;

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
    required ICore core,
    required String referer,
    this.featuredWalletIds,
    this.includedWalletIds,
    this.excludedWalletIds,
  })  : _core = core,
        _referer = referer,
        _client = http.Client();

  @override
  Future<void> init() async {
    if (initialized.value) {
      return;
    }

    await _setInstalledWalletIdsParam();
    await _fetchInitialWallets();

    initialized.value = true;
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
    loggerService.instance.d(
      '[$runtimeType] sample wallets: ${sampleWallets.length}',
    );
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
    final headers = coreUtils.instance.getAPIHeaders(
      _core.projectId,
      _referer,
    );
    final uri = Platform.isIOS
        ? Uri.parse('${UrlConstants.apiService}/getIosData')
        : Uri.parse('${UrlConstants.apiService}/getAndroidData');
    try {
      final response = await _client.get(uri, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 202) {
        final apiResponse = ApiResponse<NativeAppData>.fromJson(
          jsonDecode(response.body),
          (json) => NativeAppData.fromJson(json),
        );
        return apiResponse.data.toList();
      } else {
        loggerService.instance.d(
          '⛔ [$runtimeType] error fetching native data $uri',
          error: response.statusCode,
        );
        return <NativeAppData>[];
      }
    } catch (e) {
      loggerService.instance.e(
        '[$runtimeType] error fetching native data $uri',
        error: e,
      );
      return [];
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
    final installedWallets = await _fetchListings(params: params);
    loggerService.instance.d(
      '[$runtimeType] installed wallets: ${installedWallets.length}',
    );
    return installedWallets.setInstalledFlag();
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
    final queryParams = params?.toJson() ?? {};
    final headers = coreUtils.instance.getAPIHeaders(
      _core.projectId,
      _referer,
    );
    final uri = Uri.parse('${UrlConstants.apiService}/getWallets').replace(
      queryParameters: queryParams,
    );
    loggerService.instance.d('[$runtimeType] fetching $uri');
    try {
      final response = await _client.get(uri, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 202) {
        final apiResponse = ApiResponse<Listing>.fromJson(
          jsonDecode(response.body),
          (json) => Listing.fromJson(json),
        );
        if (updateCount) {
          totalListings.value += apiResponse.count;
        }
        return apiResponse.data.toList().toW3MWalletInfo();
      } else {
        loggerService.instance.d(
          '⛔ [$runtimeType] error fetching listings $uri',
          error: response.statusCode,
        );
        return <W3MWalletInfo>[];
      }
    } catch (e) {
      loggerService.instance.d(
        '[$runtimeType] error fetching listings: $uri',
        error: e,
      );
      return [];
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
      loggerService.instance.e(
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
    } catch (e) {
      loggerService.instance.e('[$runtimeType] updating recent wallet: $e');
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

    loggerService.instance.d('[$runtimeType] search $query');
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
    _debouncer.run(() => isSearching.value = false);
    loggerService.instance.d('[$runtimeType] _searchListings $query');
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
      final mobileLink = CoinbaseService.defaultWalletData.listing.mobileLink;
      bool installed = await urlUtils.instance.isInstalled(mobileLink);
      return wallet.copyWith(
        listing: wallet.listing.copyWith(mobileLink: mobileLink),
        installed: installed,
      );
    }
    return null;
  }

  @override
  String getWalletImageUrl(String imageId) {
    if (imageId.isEmpty) {
      return '';
    }
    if (imageId.startsWith('http')) {
      return imageId;
    }
    return '${UrlConstants.apiService}/getWalletImage/$imageId';
  }

  @override
  String getAssetImageUrl(String imageId) {
    if (imageId.isEmpty) {
      return '';
    }
    if (imageId.startsWith('http')) {
      return imageId;
    }
    return '${UrlConstants.apiService}/public/getAssetImage/$imageId';
  }

  @override
  WalletRedirect? getWalletRedirect(W3MWalletInfo? walletInfo) {
    if (walletInfo == null) return null;
    if (walletInfo.listing.id == CoinbaseService.defaultWalletData.listing.id) {
      return WalletRedirect(
        mobile: CoinbaseService.defaultWalletData.listing.mobileLink,
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
      bool installed = await urlUtils.instance.isInstalled(
        appData.schema,
        id: appData.id,
      );
      if (installed) {
        installedApps.add(appData);
      }
    }
    return installedApps;
  }
}
