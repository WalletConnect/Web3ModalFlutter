import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/walletconnect_modal_theme.dart';

class GridListItem extends StatelessWidget {
  const GridListItem({
    super.key,
    required this.title,
    required this.onSelect,
    required this.child,
    this.description,
  });

  final String title;
  final String? description;
  final void Function() onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final WalletConnectModalTheme theme = WalletConnectModalTheme.of(context);

    return InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            child,
            const SizedBox(height: 4.0),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 12.0,
                color: theme.data.foreground100,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              description ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontSize: 12.0,
                color: theme.data.foreground300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
