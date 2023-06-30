import 'package:flutter_test/flutter_test.dart';
import 'package:web3modal_flutter/services/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/services/utils/platform/platform_utils.dart';

void main() {
  final utils = PlatformUtils();

  group('Platform Utils', () {
    test('getPlatformType returns correct platform type', () {
      expect(utils.getPlatformType(), isA<PlatformType>());
    });

    test('isMobileWidth returns true when width is <= 500.0', () {
      expect(utils.isMobileWidth(500.0), isTrue);
    });

    test('isMobileWidth returns false when width is > 500.0', () {
      expect(utils.isMobileWidth(501.0), isFalse);
    });
  });
}
