// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';
import 'package:web3modal_flutter/models/launch_url_exception.dart';
import 'dart:convert';

import 'package:web3modal_flutter/models/listings.dart';
import 'package:web3modal_flutter/services/explorer/i_explorer_service.dart';
import 'package:web3modal_flutter/utils/core_util.dart';
import 'package:web3modal_flutter/utils/logger_util.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_item_model.dart';

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
  List<GridListItemModel<WalletData>> _walletList = [];
  @override
  ValueNotifier<List<GridListItemModel<WalletData>>> itemList =
      ValueNotifier([]);

  ExplorerService({
    required this.projectId,
    this.explorerUriRoot = 'https://explorer-api.walletconnect.com',
    this.recommendedWalletIds,
    this.excludedWalletState = ExcludedWalletState.list,
    this.excludedWalletIds,
  });

  @override
  Future<void> getListings({
    required String referer,
    ListingParams? params,
  }) async {
    String? platform;
    switch (Util.getPlatformType()) {
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

    LoggerUtil.logger.i('Fetching wallet listings. Platform: $platform');
    List<Listing> listings = await fetchListings(
      endpoint: '/w3m/v1/get${platform}Listings',
      referer: referer,
      params: params,
    );

    if (excludedWalletState == ExcludedWalletState.list) {
      // If we are excluding all wallets, take out the excluded listings, if they exist
      if (excludedWalletIds != null) {
        listings = filterExcludedListings(
          listings: listings,
        );
      }
    } else if (excludedWalletState == ExcludedWalletState.all &&
        recommendedWalletIds != null) {
      // Filter down to only the included
      listings = listings
          .where(
            (listing) => recommendedWalletIds!.contains(
              listing.id,
            ),
          )
          .toList();
    } else {
      // If we are excluding all wallets and have no recommended wallets,
      // return an empty list
      _walletList = [];
      itemList.value = [];
      return;
    }
    _walletList.clear();

    Map<String, int> itemCounts = {};
    for (var i in listings) {
      itemCounts[i.name] = (itemCounts[i.name] ?? 0) + 1;
    }
    print(itemCounts);

    for (Listing item in listings) {
      bool installed = await Util.isInstalled(item.mobile.native);
      _walletList.add(
        GridListItemModel<WalletData>(
          title: item.name,
          id: item.id,
          description: installed ? 'Installed' : null,
          image: getWalletImageUrl(
            imageId: item.imageId,
          ),
          data: WalletData(
            listing: item,
            installed: installed,
          ),
        ),
      );
    }

    // Sort the installed wallets to the top
    if (recommendedWalletIds != null) {
      _walletList.sort((a, b) {
        if ((a.data.installed && !b.data.installed) ||
            recommendedWalletIds!.contains(a.id)) {
          LoggerUtil.logger.i('Sorting ${a.title} to the top. ID: ${a.id}');
          return -1;
        } else if ((recommendedWalletIds!.contains(a.id) &&
                recommendedWalletIds!.contains(b.id)) ||
            (a.data.installed == b.data.installed)) {
          return 0;
        } else {
          return 1;
        }
      });
    } else {
      _walletList.sort((a, b) {
        if (a.data.installed && !b.data.installed) {
          LoggerUtil.logger.v('Sorting ${a.title} to the top. ID: ${a.id}');
          return -1;
        } else if (a.data.installed == b.data.installed) {
          return 0;
        } else {
          return 1;
        }
      });
    }

    itemList.value = _walletList;
  }

  @override
  void filterList({
    required String query,
  }) {
    if (query.isEmpty) {
      itemList.value = _walletList;
      return;
    }

    final List<GridListItemModel<WalletData>> filtered = _walletList
        .where(
          (wallet) => wallet.title.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    itemList.value = filtered;
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

  Future<List<Listing>> fetchListings({
    required String endpoint,
    required String referer,
    ListingParams? params,
  }) async {
    LoggerUtil.logger.i('Fetching wallet listings. Endpoint: $endpoint');
    final Map<String, String> headers = {
      'user-agent': CoreUtil.getUserAgent(),
      'referer': referer,
    };
    LoggerUtil.logger.i('Fetching wallet listings. Headers: $headers');
    final Uri uri = Uri.parse(explorerUriRoot + endpoint);
    final Map<String, dynamic> queryParameters = {
      'projectId': projectId,
      ...params == null ? {} : params.toJson(),
    };
    final http.Response response = await http.get(
      uri.replace(
        queryParameters: queryParameters,
      ),
      headers: headers,
    );
    // print(json.decode(response.body)['listings'].entries.first);
    ListingResponse res = ListingResponse.fromJson(json.decode(response.body));
    return res.listings.values.toList();
  }

  List<Listing> filterExcludedListings({
    required List<Listing> listings,
  }) {
    return listings.where((listing) {
      if (excludedWalletIds!.contains(
        listing.id,
      )) {
        LoggerUtil.logger.i('Excluding wallet from list: $listing');
        return false;
      }

      return true;
    }).toList();
  }
}
