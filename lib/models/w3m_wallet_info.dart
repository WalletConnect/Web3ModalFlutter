import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3modal_flutter/models/listing.dart';

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

extension W3MWalletInfoExtension on W3MWalletInfo {
  bool get isCoinbase =>
      listing.id ==
      'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa';
}
