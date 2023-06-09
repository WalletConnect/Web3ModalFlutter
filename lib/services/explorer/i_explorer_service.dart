import 'package:web3modal_flutter/models/listings.dart';

abstract class IExplorerService {
  abstract final String explorerUriRoot;
  abstract final String projectId;

  Future<ListingResponse> fetchListings({
    required String endpoint,
    ListingParams? params,
  });

  Future<ListingResponse> getDesktopListings({
    ListingParams? params,
  });

  Future<ListingResponse> getMobileListings({
    ListingParams? params,
  });

  Future<ListingResponse> getInjectedListings({
    ListingParams? params,
  });

  Future<ListingResponse> getAllListings({
    ListingParams? params,
  });

  String getWalletImageUrl({
    required String imageId,
  });

  String getAssetImageUrl({
    required String imageId,
  });
}
