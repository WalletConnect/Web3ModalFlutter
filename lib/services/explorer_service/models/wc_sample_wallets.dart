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
        'name': 'WC Wallet',
        'homepage': 'https://walletconnect.com',
        'image_id':
            'https://images.prismic.io/wallet-connect/65785a56531ac2845a260732_WalletConnect-App-Logo-1024X1024.png',
        'order': 30,
        'mobile_link': 'walletapp://',
        'app_store': 'https://apps.apple.com/app/apple-store/',
        'play_store':
            'https://play.google.com/store/apps/details?id=com.walletconnect.sample.wallet',
      }),
      installed: false,
      recent: false,
    ),
    'flutter': W3MWalletInfo(
      listing: Listing.fromJson({
        'id': '123456789012345678901234567891',
        'name': 'WC Flutter Wallet',
        'homepage': 'https://walletconnect.com',
        'image_id':
            'https://images.prismic.io/wallet-connect/65785a56531ac2845a260732_WalletConnect-App-Logo-1024X1024.png',
        'order': 30,
        'mobile_link': 'wcflutterwallet://',
        'app_store': 'https://apps.apple.com/app/apple-store/',
        'play_store':
            'https://play.google.com/store/apps/details?id=com.walletconnect.flutterwallet',
      }),
      installed: false,
      recent: false,
    ),
  };
}
