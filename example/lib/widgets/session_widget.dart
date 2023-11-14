import 'package:flutter/material.dart';

import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:walletconnect_flutter_dapp/models/chain_metadata.dart';
import 'package:walletconnect_flutter_dapp/utils/constants.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/eip155.dart';
import 'package:walletconnect_flutter_dapp/utils/crypto/helpers.dart';
import 'package:walletconnect_flutter_dapp/utils/string_constants.dart';
import 'package:walletconnect_flutter_dapp/widgets/method_dialog.dart';

class SessionWidget extends StatefulWidget {
  const SessionWidget({
    super.key,
    required this.session,
    required this.web3App,
    required this.launchRedirect,
    required this.selectedChain,
  });

  final SessionData session;
  final IWeb3App web3App;
  final W3MChainInfo selectedChain;
  final void Function() launchRedirect;

  @override
  SessionWidgetState createState() => SessionWidgetState();
}

class SessionWidgetState extends State<SessionWidget> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const SizedBox(height: StyleConstants.linear16),
      Text(
        widget.session.peer.metadata.name,
        style: Web3ModalTheme.getDataOf(context).textStyles.title600.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: StyleConstants.linear8),
      Text(
        StringConstants.sessionTopic,
        style: Web3ModalTheme.getDataOf(context).textStyles.small600.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
      ),
      Text(
        widget.session.topic,
        style: Web3ModalTheme.getDataOf(context).textStyles.small400.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
      ),
    ];

    children.addAll([
      const SizedBox(height: StyleConstants.linear8),
      Text(
        'Approved methods:',
        style: Web3ModalTheme.getDataOf(context).textStyles.small600.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
      ),
    ]);
    children.add(_buildChainApprovedMethodsTiles());
    children.add(const SizedBox.square(dimension: 8.0));

    // Get all of the accounts
    final List<String> namespaceAccounts = [];

    // Loop through the namespaces, and get the accounts
    for (final namespace in widget.session.namespaces.values) {
      namespaceAccounts.addAll(namespace.accounts);
    }

    final containsChain = namespaceAccounts.indexWhere(
      (nsa) => nsa.split(':')[1] == widget.selectedChain.chainId,
    );
    if (containsChain > -1) {
      final namespace = namespaceAccounts.firstWhere(
        (nsa) => nsa.split(':')[1] == widget.selectedChain.chainId,
      );
      children.add(_buildAccountWidget(namespace));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: children,
      ),
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
        border: Border.all(color: chainMetadata.color),
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
    final List<Widget> buttons = [];
    // Add Methods
    for (final String method in getChainMethods(chainMetadata.type)) {
      buttons.add(
        Container(
          height: StyleConstants.linear40,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: StyleConstants.linear8),
          child: ElevatedButton(
            onPressed: () async {
              final future = callChainMethod(
                chainMetadata.type,
                method,
                chainMetadata,
                address,
              );
              MethodDialog.show(context, method, future);
              widget.launchRedirect();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                chainMetadata.color,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    StyleConstants.linear8,
                  ),
                ),
              ),
            ),
            child: Text(
              method,
              style: Web3ModalTheme.getDataOf(context)
                  .textStyles
                  .small600
                  .copyWith(
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  Widget _buildChainApprovedMethodsTiles() {
    String methods = '';
    final approvedMethods = widget.session.namespaces['eip155']?.methods ?? [];
    for (final method in approvedMethods) {
      methods += '$method, ';
    }
    return Text(
      methods,
      style: Web3ModalTheme.getDataOf(context).textStyles.small400.copyWith(
            color: Web3ModalTheme.colorsOf(context).foreground100,
          ),
    );
  }

  Widget _buildChainEventsTiles(ChainMetadata chainMetadata) {
    final List<Widget> values = [];
    // Add Methods
    for (final String event in getChainEvents(chainMetadata.type)) {
      values.add(
        Container(
          // alignment: Alignment.center,
          // height: StyleConstants.linear40,
          margin: const EdgeInsets.symmetric(
            vertical: StyleConstants.linear8,
            horizontal: StyleConstants.linear8,
          ),
          padding: const EdgeInsets.all(StyleConstants.linear8),
          decoration: BoxDecoration(
            border: Border.all(
              color: chainMetadata.color,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(StyleConstants.linear8),
            ),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: values,
    );
  }

  Future<dynamic> callChainMethod(
    ChainType type,
    String method,
    ChainMetadata chainMetadata,
    String address,
  ) {
    switch (type) {
      case ChainType.eip155:
        return EIP155.callMethod(
          web3App: widget.web3App,
          topic: widget.session.topic,
          method: method.toEip155Method()!,
          chainId: chainMetadata.w3mChainInfo.namespace,
          address: address.toLowerCase(),
        );
      // case ChainType.kadena:
      //   return Kadena.callMethod(
      //     web3App: widget.web3App,
      //     topic: widget.session.topic,
      //     method: method.toKadenaMethod()!,
      //     chainId: chainMetadata.chainId,
      //     address: address.toLowerCase(),
      //   );
      default:
        return Future<dynamic>.value();
    }
  }
}
