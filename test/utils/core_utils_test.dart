import 'package:flutter_test/flutter_test.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3modal_flutter/services/utils/core/core_utils.dart';
import 'package:web3modal_flutter/utils/constants.dart';

void main() {
  final coreUtils = CoreUtils();

  group('CoreUtils', () {
    test('isHttpUrl', () {
      expect(coreUtils.isHttpUrl('http://example.com'), true);
      expect(coreUtils.isHttpUrl('https://example.com'), true);
      expect(coreUtils.isHttpUrl('ftp://example.com'), false);
    });

    test('formatNativeUrl', () {
      expect(coreUtils.formatNativeUrl(null, 'wcUri'), null);
      expect(coreUtils.formatNativeUrl('', 'wcUri'), null);
      expect(
        coreUtils.formatNativeUrl('http://example.com', 'wcUri').toString(),
        'http://example.com/wc?uri=wcUri',
      );
      expect(
        coreUtils.formatNativeUrl('myapp', 'wcUri').toString(),
        'myapp://wc?uri=wcUri',
      );
    });

    test('formatUniversalUrl', () {
      expect(coreUtils.formatUniversalUrl(null, 'wcUri'), null);
      expect(coreUtils.formatUniversalUrl('', 'wcUri'), null);
      expect(
        coreUtils.formatUniversalUrl('myapp', 'wcUri').toString(),
        'myapp://wc?uri=wcUri',
      );
      expect(
        coreUtils.formatUniversalUrl('http://example.com', 'wcUri').toString(),
        'http://example.com/wc?uri=wcUri',
      );
      expect(
        coreUtils.formatUniversalUrl('http://example.com/', 'wcUri').toString(),
        'http://example.com/wc?uri=wcUri',
      );
    });

    test('getUserAgent', () {
      final userAgent = coreUtils.getUserAgent();
      expect(userAgent.startsWith('w3m-flutter-'), true);
      expect(userAgent.contains('/flutter-core-'), true);
      expect(userAgent.contains(Web3ModalConstants.WEB3MODAL_VERSION), true);
      expect(userAgent.endsWith(WalletConnectUtils.getOS()), true);
    });
  });
}
