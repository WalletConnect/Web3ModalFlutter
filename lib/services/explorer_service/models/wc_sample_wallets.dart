import 'package:web3modal_flutter/models/listing.dart';
import 'package:web3modal_flutter/services/explorer_service/models/native_app_data.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class WCSampleWallets {
  static final nativeData = {
    // Swift Wallet
    '123456789012345678901234567890': {
      'name': 'SW Wallet',
      'platform': ['ios'],
      'ios': NativeAppData(
        id: '123456789012345678901234567890',
        schema: 'walletapp://',
      ),
      'android': NativeAppData(
        id: '123456789012345678901234567890',
        schema: 'com.walletconnect.sample.wallet',
      ),
    },
    // Flutter Wallet
    '123456789012345678901234567891': {
      'name': 'FL Wallet',
      'platform': ['ios', 'android'],
      'ios': NativeAppData(
        id: '123456789012345678901234567891',
        schema: 'wcflutterwallet://',
      ),
      'android': NativeAppData(
        id: '123456789012345678901234567891',
        schema: 'com.walletconnect.flutterwallet',
      ),
    },
    // Flutter Wallet internal
    '123456789012345678901234567895': {
      'name': 'FL Wallet (internal)',
      'platform': ['ios', 'android'],
      'ios': NativeAppData(
        id: '123456789012345678901234567895',
        schema: 'wcflutterwallet-internal://',
      ),
      'android': NativeAppData(
        id: '123456789012345678901234567895',
        schema: 'com.walletconnect.flutterwallet.internal',
      ),
    },
    // React Native Wallet
    '123456789012345678901234567892': {
      'name': 'RN Wallet (internal)',
      'platform': ['ios', 'android'],
      'ios': NativeAppData(
        id: '123456789012345678901234567892',
        schema: 'rn-web3wallet://',
      ),
      'android': NativeAppData(
        id: '123456789012345678901234567892',
        schema: 'com.walletconnect.web3wallet.rnsample',
      ),
    },
    // React Native Wallet internal
    '1234567890123456789012345678922': {
      'name': 'RN Wallet (internal)',
      'platform': ['ios', 'android'],
      'ios': NativeAppData(
        id: '1234567890123456789012345678922',
        schema: 'rn-web3wallet://',
      ),
      'android': NativeAppData(
        id: '1234567890123456789012345678922',
        schema: 'com.walletconnect.web3wallet.rnsample.internal',
      ),
    },
    // Kotlin Wallet
    '123456789012345678901234567893': {
      'name': 'KT Wallet',
      'platform': ['android'],
      'ios': NativeAppData(
        id: '123456789012345678901234567893',
        schema: 'kotlin-web3wallet://',
      ),
      'android': NativeAppData(
        id: '123456789012345678901234567893',
        schema: 'com.walletconnect.sample.wallet',
      ),
    },
    // Kotlin Wallet Internal
    '123456789012345678901234567894': {
      'name': 'KT Wallet (Internal)',
      'platform': ['android'],
      'ios': NativeAppData(
        id: '123456789012345678901234567894',
        schema: 'kotlin-web3wallet://',
      ),
      'android': NativeAppData(
        id: '123456789012345678901234567894',
        schema: 'com.walletconnect.sample.wallet.internal',
      ),
    }
  };

  static List<W3MWalletInfo> getSampleWallets(String platform) {
    final wallets = nativeData.entries.map((entry) {
      final packageId = (entry.value['android']! as NativeAppData).schema;
      final schema = (entry.value['ios']! as NativeAppData).schema;
      final platforms = entry.value['platform']! as List<String>;
      final name = entry.value['name']! as String;
      final icon =
          'https://thegraph.academy/wp-content/uploads/2021/04/WalletConnect-logo.png';
      if (platforms.contains(platform)) {
        return W3MWalletInfo(
          listing: Listing.fromJson({
            'id': entry.key,
            'name': name,
            'homepage': 'https://walletconnect.com',
            'image_id': icon,
            'order': 10,
            'mobile_link': schema,
            'app_store':
                'https://apps.apple.com/app/apple-store/id${entry.key}',
            'play_store':
                'https://play.google.com/store/apps/details?id=$packageId',
          }),
          installed: false,
          recent: false,
        );
      }
    }).toList();
    return wallets.whereType<W3MWalletInfo>().toList();
  }
}
