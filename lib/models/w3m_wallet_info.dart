import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3modal_flutter/services/explorer_service/models/api_response.dart';

part 'w3m_wallet_info.freezed.dart';
part 'w3m_wallet_info.g.dart';

@freezed
class W3MWalletInfo with _$W3MWalletInfo {
  const factory W3MWalletInfo({
    required Listing listing,
    required bool installed,
    required bool recent,
  }) = _W3MWalletInfo;

  factory W3MWalletInfo.fromJson(Map<String, dynamic> json) =>
      _$W3MWalletInfoFromJson(json);
}
