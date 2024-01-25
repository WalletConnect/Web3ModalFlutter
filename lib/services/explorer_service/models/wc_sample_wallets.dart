import 'package:web3modal_flutter/services/explorer_service/models/api_response.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class WCSampleWallets {
  static final nativeData = {
    '123456789012345678901234567890': {
      'ios': NativeAppData(
        id: '123456789012345678901234567890',
        schema: 'walletapp://',
      ),
      'android': NativeAppData(
        id: '123456789012345678901234567890',
        schema: 'com.walletconnect.sample.wallet',
      ),
    },
    '123456789012345678901234567891': {
      'ios': NativeAppData(
        id: '123456789012345678901234567890',
        schema: 'wcflutterwallet://',
      ),
      'android': NativeAppData(
        id: '123456789012345678901234567890',
        schema: 'com.walletconnect.flutterwallet',
      ),
    }
  };

  static final wallets = {
    'ios': W3MWalletInfo(
      listing: Listing.fromJson({
        'id': '123456789012345678901234567890',
        'name': 'Wallet (Swift)',
        'homepage': 'https://walletconnect.com',
        'image_id': _walletImage,
        'order': 30,
        'mobile_link': 'walletapp://',
        'app_store': 'https://apps.apple.com/app/apple-store/',
        'play_store':
            '$_playstoreUrl${nativeData["123456789012345678901234567890"]?["android"]?.schema}',
      }),
      installed: false,
      recent: false,
    ),
    'flutter': W3MWalletInfo(
      listing: Listing.fromJson({
        'id': '123456789012345678901234567891',
        'name': 'Wallet (Flutter)',
        'homepage': 'https://walletconnect.com',
        'image_id': _walletImage,
        'order': 30,
        'mobile_link': 'wcflutterwallet://',
        'app_store': 'https://apps.apple.com/app/apple-store/',
        'play_store':
            '$_playstoreUrl${nativeData["123456789012345678901234567891"]?["android"]?.schema}',
      }),
      installed: false,
      recent: false,
    ),
  };

  static const _playstoreUrl = 'https://play.google.com/store/apps/details?id=';
  static const _walletImage =
      'https://docs.walletconnect.com/assets/images/web3walletLogo-54d3b546146931ceaf47a3500868a73a.png';
}
