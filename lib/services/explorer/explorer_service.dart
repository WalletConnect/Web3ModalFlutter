// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:web3modal_flutter/models/listings.dart';
import 'package:web3modal_flutter/services/explorer/i_explorer_service.dart';

class ExplorerService implements IExplorerService {
  @override
  final String explorerUriRoot;

  @override
  final String projectId;

  ExplorerService({
    required this.projectId,
    this.explorerUriRoot = 'https://explorer-api.walletconnect.com',
  });

  @override
  Future<ListingResponse> fetchListings({
    required String endpoint,
    ListingParams? params,
  }) async {
    final Uri uri = Uri.parse(explorerUriRoot + endpoint);
    final Map<String, dynamic> queryParameters = {
      'projectId': projectId,
      ...params == null ? {} : params.toJson(),
    };
    final http.Response response = await http.get(
      uri.replace(
        queryParameters: queryParameters,
      ),
    );
    // print(json.decode(response.body)['listings'].entries.first);
    return ListingResponse.fromJson(json.decode(response.body));
  }

  @override
  Future<ListingResponse> getDesktopListings({
    ListingParams? params,
  }) async {
    return fetchListings(
      endpoint: '/w3m/v1/getDesktopListings',
      params: params,
    );
  }

  @override
  Future<ListingResponse> getMobileListings({
    ListingParams? params,
  }) async {
    return fetchListings(
      endpoint: '/w3m/v1/getMobileListings',
      params: params,
    );
  }

  @override
  Future<ListingResponse> getInjectedListings({
    ListingParams? params,
  }) async {
    return fetchListings(
      endpoint: '/w3m/v1/getInjectedListings',
      params: params,
    );
  }

  @override
  Future<ListingResponse> getAllListings({
    ListingParams? params,
  }) async {
    return fetchListings(
      endpoint: '/w3m/v1/getAllListings',
      params: params,
    );
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
}
