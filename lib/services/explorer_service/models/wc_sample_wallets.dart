import 'package:web3modal_flutter/models/listing.dart';
import 'package:web3modal_flutter/services/explorer_service/models/native_app_data.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class WCSampleWallets {
  static final nativeData = {
    // Swift Wallet
    '123456789012345678901234567890': {
      'name': 'Wallet (Swift)',
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
      'name': 'Wallet (Flutter)',
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
    // React Native Wallet
    '123456789012345678901234567892': {
      'name': 'Wallet (RN)',
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
    // Kotlin Wallet
    '123456789012345678901234567893': {
      'name': 'Wallet (Kotlin)',
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
      'name': 'Wallet (Kotlin Internal)',
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
      if (platforms.contains(platform)) {
        return W3MWalletInfo(
          listing: Listing.fromJson({
            'id': entry.key,
            'name': name,
            'homepage': 'https://walletconnect.com',
            'image_id': _walletImage,
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

  static const _walletImage =
      'https://docs.walletconnect.com/assets/images/web3walletLogo-54d3b546146931ceaf47a3500868a73a.png';
}
