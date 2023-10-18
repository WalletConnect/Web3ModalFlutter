import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/widgets/buttons/balance_button.dart';
import 'package:web3modal_flutter/widgets/w3m_connect_wallet_button.dart';

import '../mock_classes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('W3MConnect', () {
    late W3MServiceSpy service;

    const String address = '0x5b92E49e1b7d275dC7BBCc37b2eFAf131bF4C5fD';

    setUp(() async {
      service = W3MServiceSpy();
      when(service.initError).thenReturn(null);
      when(service.isConnected).thenReturn(false);
      when(service.isOpen).thenReturn(false);
      when(service.address).thenReturn(address);
      when(service.chainBalance).thenReturn(null);
      when(service.tokenImageUrl).thenReturn(null);
      when(service.selectedChain).thenReturn(null);
      when(service.avatarUrl).thenReturn(null);
    });

    testWidgets('should open or open modal with account page on tap',
        (WidgetTester tester) async {
      // FlutterError.onError = ignoreOverflowErrors;
      await tester.binding.setSurfaceSize(const Size(1000, 1000));

      final GlobalKey key = GlobalKey();
      // late BuildContext context;

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 100,
              child: Builder(
                builder: (context) {
                  return W3MConnectWalletButton(
                    key: key,
                    service: service,
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Idle state
      expect(
        find.text(
          StringConstants.connectButtonIdle,
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(key));
      await tester.pump();

      verify(service.openModal(anyNamed('context'))).called(1);

      // Connecting state
      when(service.isConnected).thenReturn(false);
      when(service.isOpen).thenReturn(true);
      service.notifyListeners();

      await tester.pump();

      expect(
        find.text(
          StringConstants.connectButtonConnecting,
          skipOffstage: false,
        ),
        findsOneWidget,
      );

      // Account State
      when(service.isConnected).thenReturn(true);
      when(service.isOpen).thenReturn(false);
      service.notifyListeners();

      await tester.pumpAndSettle();

      expect(
        find.text(BalanceButton.balanceDefault),
        findsOneWidget,
      );
      expect(
        find.text(Util.truncate(address)),
        findsOneWidget,
      );

      when(service.chainBalance).thenReturn(0.0);
      service.notifyListeners();
      await tester.pumpAndSettle();

      expect(
        find.text('0'),
        findsOneWidget,
      );

      // Opens modal
      await tester.tap(
        find.byKey(
          Web3ModalKeyConstants.w3mAccountButton,
        ),
      );

      await tester.pump();

      verify(
        service.openModal(anyNamed('context'), anyNamed('startWidget')),
      ).called(1);
    });
  });
}
