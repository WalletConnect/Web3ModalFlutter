import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3modal_flutter/models/launch_url_exception.dart';
import 'package:web3modal_flutter/services/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/services/utils/platform/platform_utils_singleton.dart';
import 'package:web3modal_flutter/services/utils/url/url_utils.dart';

import '../mock_classes.mocks.dart';

class MockLaunchUrl extends Mock {
  Future<bool> call(
    Uri? url, {
    LaunchMode? mode = LaunchMode.platformDefault,
  }) =>
      super.noSuchMethod(
        Invocation.method(#call, [url], {#mode: mode}),
        returnValue: Future.value(true),
        returnValueForMissingStub: Future.value(true),
      );
}

class MockCanLaunchUrl extends Mock {
  Future<bool> call(Uri? url) => super.noSuchMethod(
        Invocation.method(#call, [url]),
        returnValue: Future.value(true),
        returnValueForMissingStub: Future.value(true),
      );
}

void main() {
  final mockLaunchUrl = MockLaunchUrl();
  final mockCanLaunchUrl = MockCanLaunchUrl();

  final utils = UrlUtils(
    launchUrlFunc: mockLaunchUrl.call,
    canLaunchUrlFunc: mockCanLaunchUrl.call,
  );

  platformUtils.instance = MockPlatformUtils();
  when(
    platformUtils.instance.getPlatformType(),
  ).thenReturn(PlatformType.mobile);

  group('Url Utils', () {
    test('isInstalled returns false when URI is null or empty', () async {
      expect(await utils.isInstalled(null), isFalse);
      expect(await utils.isInstalled(''), isFalse);
    });

    test('isInstalled calls canLaunchUrl function when URI is valid', () async {
      await utils.isInstalled('https://example.com');
      verify(
        mockCanLaunchUrl.call(
          Uri.parse('https://example.com'),
        ),
      ).called(1);
    });

    group('launchRedirect', () {
      test('calls launchUrl function when nativeUri is valid', () async {
        final uri = Uri.parse('https://native.com');
        await utils.launchRedirect(
          nativeUri: uri,
          universalUri: Uri.parse('https://universal.com'),
        );

        verify(
          mockCanLaunchUrl.call(
            uri,
          ),
        ).called(1);
        verify(
          mockLaunchUrl.call(
            uri,
            mode: LaunchMode.externalApplication,
          ),
        ).called(1);
      });

      test('calls launchUrl on universal when nativeUri is invalid', () async {
        final native = Uri.parse('https://native.com');
        final universal = Uri.parse('https://universal.com');

        // Case 1: Native is null
        await utils.launchRedirect(
          nativeUri: null,
          universalUri: universal,
        );

        verifyNever(
          mockCanLaunchUrl.call(
            native,
          ),
        );
        verify(
          mockCanLaunchUrl.call(
            universal,
          ),
        ).called(1);
        verify(
          mockLaunchUrl.call(
            universal,
            mode: LaunchMode.externalApplication,
          ),
        ).called(1);

        // Case 2: Native is invalid
        when(mockCanLaunchUrl.call(native)).thenAnswer(
          (realInvocation) => Future.value(false),
        );
        await utils.launchRedirect(
          nativeUri: native,
          universalUri: universal,
        );

        verify(
          mockCanLaunchUrl.call(
            native,
          ),
        ).called(1);
        verify(
          mockCanLaunchUrl.call(
            universal,
          ),
        ).called(1);
        verify(
          mockLaunchUrl.call(
            universal,
            mode: LaunchMode.externalApplication,
          ),
        ).called(1);

        // Case 3: Native can launch, but launch throws error
        when(mockCanLaunchUrl.call(native)).thenAnswer(
          (realInvocation) => Future.value(true),
        );
        when(mockLaunchUrl.call(native, mode: anyNamed('mode'))).thenThrow(
          Exception('Unable to launch'),
        );

        await utils.launchRedirect(
          nativeUri: native,
          universalUri: universal,
        );

        verify(
          mockCanLaunchUrl.call(
            native,
          ),
        ).called(1);
        verify(
          mockLaunchUrl.call(
            native,
            mode: LaunchMode.externalApplication,
          ),
        ).called(1);
        verify(
          mockCanLaunchUrl.call(
            universal,
          ),
        ).called(1);
        verify(
          mockLaunchUrl.call(
            universal,
            mode: LaunchMode.externalApplication,
          ),
        ).called(1);

        // Case 4: Neither native nor universal launch successfully
      });

      test(
          'throws LaunchUrlException when nativeUri and universalUri are null or invalid',
          () async {
        final native = Uri.parse('https://universal.com');
        final universal = Uri.parse('https://universal.com');
        when(mockCanLaunchUrl.call(any)).thenAnswer((_) => Future.value(false));

        try {
          await utils.launchRedirect(
            nativeUri: null,
            universalUri: null,
          );
        } catch (e) {
          expect(e, isA<LaunchUrlException>());
          expect(
            (e as LaunchUrlException).message,
            'Unable to open the wallet',
          );
        }

        try {
          await utils.launchRedirect(
            nativeUri: native,
            universalUri: universal,
          );
        } catch (e) {
          expect(e, isA<LaunchUrlException>());
          expect(
            (e as LaunchUrlException).message,
            'Unable to open the wallet',
          );
        }

        when(mockCanLaunchUrl.call(native)).thenAnswer(
          (realInvocation) => Future.value(true),
        );
        when(mockCanLaunchUrl.call(universal)).thenAnswer(
          (realInvocation) => Future.value(false),
        );
        when(mockLaunchUrl.call(native, mode: anyNamed('mode'))).thenThrow(
          Exception('Unable to launch'),
        );
        try {
          await utils.launchRedirect(
            nativeUri: native,
            universalUri: universal,
          );
        } catch (e) {
          expect(e, isA<LaunchUrlException>());
          expect(
            (e as LaunchUrlException).message,
            'Unable to open the wallet',
          );
        }
      });
    });

    test('navigateDeepLink calls launchRedirect function when links are valid',
        () async {
      when(mockCanLaunchUrl.call(any)).thenAnswer(
        (realInvocation) => Future.value(true),
      );
      await utils.navigateDeepLink(
        nativeLink: 'https://native.com',
        universalLink: 'https://universal.com',
        wcURI: 'https://wc.com',
      );
      verify(
        mockLaunchUrl.call(
          any,
          mode: anyNamed('mode'),
        ),
      ).called(1);
    });
  });
}
