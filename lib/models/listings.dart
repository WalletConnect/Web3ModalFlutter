import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

part 'listings.freezed.dart';
part 'listings.g.dart';

// @JsonSerializable(includeIfNull: false)
@freezed
class WalletData with _$WalletData {
  @JsonSerializable(includeIfNull: false)
  const factory WalletData({
    required Listing listing,
    required bool installed,
  }) = _WalletData;

  factory WalletData.fromJson(Map<String, dynamic> json) =>
      _$WalletDataFromJson(json);
}

@freezed
class ListingResponse with _$ListingResponse {
  @JsonSerializable(includeIfNull: false)
  const factory ListingResponse({
    required Map<String, Listing> listings,
    required int total,
  }) = _ListingResponse;

  factory ListingResponse.fromJson(Map<String, dynamic> json) =>
      _$ListingResponseFromJson(json);
}

@freezed
class Listing with _$Listing {
  @JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
  const factory Listing({
    required String id,
    required String name,
    required String homepage,
    required String imageId,
    required App app,
    List<Injected>? injected,
    required Redirect mobile,
    required Redirect desktop,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);
}

@freezed
class App with _$App {
  @JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
  const factory App({
    String? browser,
    String? ios,
    String? android,
    String? mac,
    String? windows,
    String? linux,
    String? chrome,
    String? firefox,
    String? safari,
    String? edge,
    String? opera,
  }) = _App;

  factory App.fromJson(Map<String, dynamic> json) => _$AppFromJson(json);
}

@freezed
class Injected with _$Injected {
  @JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
  const factory Injected({
    required String injectedId,
    required String namespace,
  }) = _Injected;

  factory Injected.fromJson(Map<String, dynamic> json) =>
      _$InjectedFromJson(json);
}

@freezed
class ListingParams with _$ListingParams {
  @JsonSerializable(includeIfNull: false)
  const factory ListingParams({
    int? page,
    String? search,
    int? entries,
    int? version,
    String? chains,
    String? recommendedIds,
    String? excludedIds,
    String? sdks,
  }) = _ListingParams;

  factory ListingParams.fromJson(Map<String, dynamic> json) =>
      _$ListingParamsFromJson(json);
}
