import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/pages/account_page.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/buttons/balance_button.dart';

import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import 'package:web3modal_flutter/utils/platform/i_platform_utils.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils_singleton.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';

import '../mock_classes.dart';
import '../mock_classes.mocks.dart';
import '../test_data.dart';

void main() {
  group('AccountPage', () {
    late W3MServiceSpy service;
    late MockWeb3App web3App;
    late MockSessions sessions;
    late MockWidgetStack mockWidgetStack;
    late MockToastUtils mockToastUtils;
    late MockExplorerService es;
    final MockPlatformUtils mockPlatformUtils = MockPlatformUtils();

    const String address = '0x5b92E49e1b7d275dC7BBCc37b2eFAf131bF4C5fD';

    setUp(() async {
      // Setup the singletons
      when(mockPlatformUtils.getPlatformType()).thenReturn(PlatformType.mobile);
      when(mockPlatformUtils.isMobileWidth(any)).thenReturn(true);
      web3App = MockWeb3App();
      when(web3App.core).thenReturn(
        Core(projectId: 'projectId'),
      );
      when(web3App.metadata).thenReturn(
        metadata,
      );
      when(web3App.onSessionDelete).thenReturn(
        Event<SessionDelete>(),
      );

      mockWidgetStack = MockWidgetStack();
      widgetStack.instance = mockWidgetStack;

      mockToastUtils = MockToastUtils();
      toastUtils.instance = mockToastUtils;

      sessions = MockSessions();
      when(web3App.sessions).thenReturn(
        sessions,
      );
      when(sessions.getAll()).thenReturn(
        [],
      );
      es = MockExplorerService();
      when(es.initialized).thenReturn(ValueNotifier(true));
      when(es.listings).thenReturn(ValueNotifier(itemList));
      explorerService.instance = es;

      service = W3MServiceSpy();
      when(service.isConnected).thenReturn(true);
      when(service.wcUri).thenReturn('test');
      when(service.status).thenReturn(W3MServiceStatus.initialized);
      when(service.isOpen).thenReturn(true);
      when(service.address).thenReturn(address);
      when(service.chainBalance).thenReturn(null);
      when(service.tokenImageUrl).thenReturn(null);
      when(service.selectedChain).thenReturn(null);
      when(service.avatarUrl).thenReturn(null);
    });

    testWidgets('happy path', (WidgetTester tester) async {
      // FlutterError.onError = ignoreOverflowErrors;
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      await mockNetworkImagesFor(() async {
        // Build our app and trigger a frame.
        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              height: 800,
              width: 800,
              child: Center(
                child: Web3ModalProvider(
                  service: service,
                  child: Scaffold(
                    body: Builder(
                      builder: (context) {
                        return const AccountPage();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Connected chip
        expect(
          find.text(
            StringConstants.connected,
            skipOffstage: false,
          ),
          findsOneWidget,
        );

        // Address
        expect(
          find.text(
            Util.truncate(address),
            skipOffstage: false,
          ),
          findsOneWidget,
        );

        // Balance
        expect(
          find.text(
            BalanceButton.balanceDefault,
            skipOffstage: false,
          ),
          findsOneWidget,
        );

        // Chain swap button works
        expect(
          find.text(
            StringConstants.noChain,
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        await tester.tap(find.byKey(
          Web3ModalKeyConstants.chainSwapButton,
        ));

        await tester.pump();

        verify(mockWidgetStack.push(any)).called(1);

        // Copy address button works
        expect(
          find.text(
            StringConstants.copyAddress,
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        await tester.tap(find.byKey(
          Web3ModalKeyConstants.addressCopyButton,
        ));

        verify(mockToastUtils.show(any)).called(1);

        // Disconnect button works
        expect(
          find.text(
            StringConstants.disconnect,
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        await tester.tap(find.byKey(
          Web3ModalKeyConstants.disconnectButton,
        ));

        verify(service.disconnect()).called(1);
      });
    });
  });
}
