import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_dapp/home_page.dart';

import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_flutter_dapp/models/chain_metadata.dart';
import 'package:walletconnect_flutter_dapp/utils/constants.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/eip155.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/helpers.dart';
import 'package:walletconnect_flutter_dapp/utils/string_constants.dart';
import 'package:walletconnect_flutter_dapp/widgets/method_dialog.dart';

class SessionWidget extends StatefulWidget {
  const SessionWidget({super.key, required this.w3mService});

  final W3MService w3mService;

  @override
  SessionWidgetState createState() => SessionWidgetState();
}

class SessionWidgetState extends State<SessionWidget> {
  @override
  Widget build(BuildContext context) {
    final session = widget.w3mService.session!;
    String iconImage = '';
    if ((session.peer?.metadata.icons ?? []).isNotEmpty) {
      iconImage = session.peer?.metadata.icons.first ?? '';
    }
    final List<Widget> children = [
      const SizedBox(height: StyleConstants.linear16),
      Row(
        children: [
          if (iconImage.isNotEmpty)
            Row(
              children: [
                CircleAvatar(
                  radius: 25.0,
                  backgroundImage: NetworkImage(iconImage),
                ),
                const SizedBox(width: 10.0),
              ],
            ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    session.connectedWalletName ?? '',
                    style: Web3ModalTheme.getDataOf(context)
                        .textStyles
                        .large600
                        .copyWith(
                          color: Web3ModalTheme.colorsOf(context).foreground100,
                        ),
                  ),
                ),
                Visibility(
                  visible: !session.sessionService.isMagic,
                  child: IconButton(
                    onPressed: () {
                      widget.w3mService.launchConnectedWallet();
                    },
                    icon: const Icon(Icons.open_in_new),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: StyleConstants.linear16),
      // TOPIC LABEL
      Visibility(
        visible: session.topic != null,
        child: Column(
          children: [
            Text(
              StringConstants.sessionTopic,
              style: Web3ModalTheme.getDataOf(context)
                  .textStyles
                  .small600
                  .copyWith(
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
            ),
            Text(
              '${session.topic}',
              style: Web3ModalTheme.getDataOf(context)
                  .textStyles
                  .small400
                  .copyWith(
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
            ),
          ],
        ),
      ),
      Column(
        children: _buildSupportedChainsWidget(),
      ),
      const SizedBox(height: StyleConstants.linear8),
    ];

    // Get current active account
    final accounts = session.getAccounts() ?? [];
    try {
      final currentNamespace = widget.w3mService.selectedChain?.namespace;
      final chainsNamespaces = NamespaceUtils.getChainsFromAccounts(accounts);
      if (chainsNamespaces.contains(currentNamespace)) {
        final account = accounts.firstWhere(
          (account) => account.contains('$currentNamespace:'),
        );
        children.add(_buildAccountWidget(account));
      }
    } catch (e) {
      debugPrint('[ExampleApp] ${e.toString()}');
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Column(children: children),
    );
  }

  Widget _buildAccountWidget(String namespaceAccount) {
    final chainId = NamespaceUtils.getChainFromAccount(namespaceAccount);
    final account = NamespaceUtils.getAccount(namespaceAccount);
    final chainMetadata = getChainMetadataFromChain(chainId);

    final List<Widget> children = [
      Text(
        chainMetadata.w3mChainInfo.chainName,
        style: Web3ModalTheme.getDataOf(context).textStyles.title600.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
      ),
      const SizedBox(height: StyleConstants.linear8),
      Text(
        account,
        style: Web3ModalTheme.getDataOf(context).textStyles.small400.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
      ),
    ];

    children.addAll([
      const SizedBox(height: StyleConstants.linear8),
      Text(
        StringConstants.methods,
        style:
            Web3ModalTheme.getDataOf(context).textStyles.paragraph600.copyWith(
                  color: Web3ModalTheme.colorsOf(context).foreground100,
                ),
      ),
    ]);
    children.addAll(_buildChainMethodButtons(chainMetadata, account));

    children.addAll([
      const SizedBox(height: StyleConstants.linear8),
      Text(
        StringConstants.events,
        style:
            Web3ModalTheme.getDataOf(context).textStyles.paragraph600.copyWith(
                  color: Web3ModalTheme.colorsOf(context).foreground100,
                ),
      ),
    ]);
    children.add(_buildChainEventsTiles(chainMetadata));

    return Container(
      padding: const EdgeInsets.all(StyleConstants.linear8),
      margin: const EdgeInsets.symmetric(vertical: StyleConstants.linear8),
      decoration: BoxDecoration(
        border: Border.all(color: Web3ModalTheme.colorsOf(context).accent100),
        borderRadius: const BorderRadius.all(
          Radius.circular(StyleConstants.linear8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  List<Widget> _buildChainMethodButtons(
    ChainMetadata chainMetadata,
    String address,
  ) {
    // Add Methods
    final approvedMethods =
        widget.w3mService.getApprovedMethods() ?? <String>[];
    if (approvedMethods.isEmpty) {
      return [
        Text(
          'No methods approved',
          style: Web3ModalTheme.getDataOf(context).textStyles.small400.copyWith(
                color: Web3ModalTheme.colorsOf(context).foreground100,
              ),
        )
      ];
    }
    final usableMethods = EIP155UIMethods.values.map((e) => e.name).toList();
    //
    final List<Widget> children = [];
    for (final method in approvedMethods) {
      final implemented = usableMethods.contains(method);
      children.add(
        Container(
          height: StyleConstants.linear40,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: StyleConstants.linear8),
          child: ElevatedButton(
            onPressed: implemented
                ? () async {
                    widget.w3mService.launchConnectedWallet();
                    final future = callChainMethod(
                      chainMetadata.type,
                      EIP155.methodFromName(method),
                      chainMetadata,
                      address,
                    );
                    MethodDialog.show(context, method, future);
                  }
                : null,
            style: buttonStyle(context),
            child: Text(method),
          ),
        ),
      );
    }

    children.add(const Divider());
    final onSepolia = chainMetadata.w3mChainInfo.chainId == '11155111';
    if (!onSepolia) {
      children.add(const Text('Connect to Sepolia to Test'));
    }

    children.addAll([
      Container(
        height: StyleConstants.linear40,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: StyleConstants.linear8),
        child: ElevatedButton(
          onPressed: onSepolia
              ? () async {
                  final future = EIP155.callSmartContract(
                    w3mService: widget.w3mService,
                    action: 'read',
                  );
                  MethodDialog.show(context, 'Test Contract (Read)', future);
                }
              : null,
          style: buttonStyle(context),
          child: const Text('Test Contract (Read)'),
        ),
      ),
      Container(
        height: StyleConstants.linear40,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: StyleConstants.linear8),
        child: ElevatedButton(
          onPressed: onSepolia
              ? () async {
                  widget.w3mService.launchConnectedWallet();
                  final future = EIP155.callSmartContract(
                    w3mService: widget.w3mService,
                    action: 'write',
                  );
                  MethodDialog.show(context, 'Test Contract (Write)', future);
                }
              : null,
          style: buttonStyle(context),
          child: const Text('Test Contract (Write)'),
        ),
      ),
    ]);

    return children;
  }

  List<Widget> _buildSupportedChainsWidget() {
    List<Widget> children = [];
    children.addAll(
      [
        const SizedBox(height: StyleConstants.linear8),
        Text(
          'Supported chains:',
          style: Web3ModalTheme.getDataOf(context).textStyles.small600.copyWith(
                color: Web3ModalTheme.colorsOf(context).foreground100,
              ),
        ),
      ],
    );
    final approvedChains = widget.w3mService.getApprovedChains() ?? <String>[];
    children.add(
      Text(
        approvedChains.join(', '),
        style: Web3ModalTheme.getDataOf(context).textStyles.small400.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
      ),
    );
    return children;
  }

  Widget _buildChainEventsTiles(ChainMetadata chainMetadata) {
    // Add Events
    final approvedEvents = widget.w3mService.getApprovedEvents() ?? <String>[];
    if (approvedEvents.isEmpty) {
      return Text(
        'No events approved',
        style: Web3ModalTheme.getDataOf(context).textStyles.small400.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
      );
    }
    final List<Widget> children = [];
    for (final event in approvedEvents) {
      children.add(
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: StyleConstants.linear8,
            horizontal: StyleConstants.linear8,
          ),
          padding: const EdgeInsets.all(StyleConstants.linear8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Web3ModalTheme.colorsOf(context).accent100,
            ),
            borderRadius: borderRadius(context),
          ),
          child: Text(
            event,
            style:
                Web3ModalTheme.getDataOf(context).textStyles.small400.copyWith(
                      color: Web3ModalTheme.colorsOf(context).foreground100,
                    ),
          ),
        ),
      );
    }

    return Wrap(
      children: children,
    );
  }

  Future<dynamic> callChainMethod(
    ChainType type,
    EIP155UIMethods method,
    ChainMetadata chainMetadata,
    String address,
  ) {
    final session = widget.w3mService.session!;
    switch (type) {
      case ChainType.eip155:
        return EIP155.callMethod(
          w3mService: widget.w3mService,
          topic: session.topic ?? '',
          method: method,
          chainId: chainMetadata.w3mChainInfo.namespace,
          address: address.toLowerCase(),
        );
      default:
        return Future<dynamic>.value();
    }
  }
}
