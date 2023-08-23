// ignore_for_file: depend_on_referenced_packages

import 'package:event/event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:walletconnect_modal_flutter/services/explorer/explorer_service_singleton.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_api_utils_singleton.dart';
import 'package:web3modal_flutter/services/blockchain_api_service/blockchain_identity.dart';
import 'package:web3modal_flutter/services/network_service.dart/network_service_singleton.dart';
import 'package:web3modal_flutter/services/storage_service/storage_service_singleton.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/utils/eth_util.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import '../mock_classes.mocks.dart';
import '../test_data.dart';

void main() {
  group('WalletConnectModalService', () {
    late W3MService service;
    late MockWeb3App web3App;
    late MockSessions sessions;
    late MockExplorerService es;
    late Core core;
    late MockRelayClient mockRelayClient;
    late MockNetworkService mockNetworkService;
    late MockStorageService mockStorageService;
    late MockBlockchainApiUtils mockBlockchainApiUtils;
    late MockEVMService mockEVMService;

    setUp(() async {
      // Web3App Mocking
      web3App = MockWeb3App();
      when(web3App.init()).thenAnswer((_) async {});
      core = Core(projectId: 'projectId');
      mockRelayClient = MockRelayClient();
      when(mockRelayClient.onRelayClientError).thenReturn(Event<ErrorEvent>());
      when(mockRelayClient.onRelayClientConnect).thenReturn(Event<EventArgs>());
      core.relayClient = mockRelayClient;
      when(web3App.core).thenReturn(
        core,
      );
      when(web3App.metadata).thenReturn(
        metadata,
      );
      when(web3App.onSessionDelete).thenReturn(
        Event<SessionDelete>(),
      );
      when(web3App.onSessionConnect).thenReturn(
        Event<SessionConnect>(),
      );
      when(web3App.onSessionUpdate).thenReturn(
        Event<SessionUpdate>(),
      );
      when(web3App.onSessionEvent).thenReturn(
        Event<SessionEvent>(),
      );
      when(
        web3App.request(
          topic: anyNamed('topic'),
          chainId: anyNamed('chainId'),
          request: anyNamed('request'),
        ),
      ).thenAnswer((_) => Future.value(true));
      sessions = MockSessions();
      when(web3App.sessions).thenReturn(
        sessions,
      );
      when(sessions.getAll()).thenReturn(
        [],
      );

      service = W3MService(
        web3App: web3App,
      );

      // Service mocking
      mockNetworkService = MockNetworkService();
      mockStorageService = MockStorageService();
      mockBlockchainApiUtils = MockBlockchainApiUtils();
      es = MockExplorerService();
      mockEVMService = MockEVMService();
      networkService.instance = mockNetworkService;
      storageService.instance = mockStorageService;
      explorerService.instance = es;
      blockchainApiUtils.instance = mockBlockchainApiUtils;
      ChainData.chainPresets['1'] = ChainData.chainPresets['1']!.copyWith(
        ledgerService: mockEVMService,
      );

      when(es.init()).thenAnswer((_) async {});
      // await WalletConnectModalServices.explorer.init();
      when(mockStorageService.getString(W3MService.selectedChainId))
          .thenReturn('1');
      when(mockStorageService.setString(W3MService.selectedChainId, '1'))
          .thenAnswer((_) => Future.value(true));
      when(
        es.getAssetImageUrl(
          imageId: AssetUtil.getChainIconAssetId(
            '1',
          ),
        ),
      ).thenReturn('abc');
      when(mockEVMService.getBalance(any, any)).thenAnswer(
        (_) => Future.value(1.0),
      );
      when(mockBlockchainApiUtils.getIdentity(any, any)).thenAnswer(
        (realInvocation) => Future.value(
          const BlockchainIdentity(
            avatar: null,
            name: null,
          ),
        ),
      );
    });

    group('Constructor', () {
      test('initializes blockchainApiUtils with projectId', () {
        W3MService(
          projectId: 'projectId',
          metadata: metadata,
        );

        expect(blockchainApiUtils.instance!.projectId, 'projectId');
      });
    });

    group('init', () {
      test(
          'should call init on services, set optional namespaces, then skip init again',
          () async {
        when(es.init()).thenAnswer((_) async {});

        await service.init();

        verify(mockNetworkService.init()).called(1);
        verify(mockStorageService.init()).called(1);

        expect(service.isInitialized, isTrue);
        final List<String> chainIds = [];
        for (final String id in ChainData.chainPresets.keys) {
          chainIds.add('eip155:$id');
        }
        final Map<String, RequiredNamespace> optionalNamespaces = {
          'eip155': RequiredNamespace(
            methods: EthUtil.ethMethods,
            chains: chainIds,
            events: EthUtil.ethEvents,
          ),
        };
        expect(
          service.optionalNamespaces,
          optionalNamespaces,
        );

        await service.init();

        verifyNever(mockNetworkService.init());
        verifyNever(mockStorageService.init());

        expect(service.isInitialized, isTrue);
      });

      test(
          'should setSelectedChain if sessions is not empty and we have a stored selectedChainId',
          () async {
        when(sessions.getAll()).thenReturn(
          [testSession],
        );

        await service.init();

        verify(
          mockStorageService.getString(W3MService.selectedChainId),
        ).called(1);
        verify(
          mockStorageService.setString(W3MService.selectedChainId, '1'),
        ).called(1);
        verify(es.getAssetImageUrl(imageId: anyNamed('imageId'))).called(1);
        verify(mockEVMService.getBalance(any, any)).called(1);
        verify(mockBlockchainApiUtils.getIdentity(any, any)).called(1);
        expect(service.selectedChain, ChainData.chainPresets['1']);
      });
    });

    group('setSelectedChain', () {
      test('throws if _checkInitialized fails', () async {
        expect(
          () => service.setSelectedChain(ChainData.chainPresets['1']!),
          throwsA(isA<StateError>()),
        );
      });

      test('happy path + null chain', () async {
        when(sessions.getAll()).thenReturn(
          [testSession],
        );

        await service.init();

        await service.setSelectedChain(ChainData.chainPresets['1']!);

        verify(
          mockStorageService.setString(W3MService.selectedChainId, '1'),
        ).called(1);
        verify(es.getAssetImageUrl(imageId: anyNamed('imageId'))).called(1);
        verify(mockEVMService.getBalance(any, any)).called(1);
        verify(mockBlockchainApiUtils.getIdentity(any, any)).called(1);
        expect(service.selectedChain, ChainData.chainPresets['1']);

        verifyNever(mockStorageService.setString(
          W3MService.selectedChainId,
          '1',
        ));

        await service.setSelectedChain(null);

        verifyNever(mockStorageService.setString(
          W3MService.selectedChainId,
          '1',
        ));
        expect(service.session != null, true);
        verify(
          web3App.disconnectSession(
            topic: anyNamed('topic'),
            reason: anyNamed('reason'),
          ),
        ).called(2);
        expect(service.selectedChain, null);
        expect(service.chainBalance, null);
        expect(service.tokenImageUrl, null);
      });
    });
  });
}
