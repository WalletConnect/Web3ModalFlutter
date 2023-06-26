import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3modal_flutter/models/listings.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/web3modal_button.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_item_model.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list_provider.dart';
import 'package:web3modal_flutter/widgets/wallet_image.dart';

class GetWalletPage extends StatelessWidget {
  const GetWalletPage({
    super.key,
    required this.service,
  });

  final GridListProvider<WalletData> service;

  @override
  Widget build(BuildContext context) {
    final Web3ModalTheme theme = Web3ModalTheme.of(context);

    List<GridListItemModel<WalletData>> wallets = service.itemList.value
        .where((GridListItemModel<WalletData> w) => !w.data.installed)
        .take(6)
        .toList();

    return Column(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children:
              wallets.map((wallet) => WalletItem(wallet: wallet)).toList(),
        ),
        const SizedBox(height: 8.0),
        Text(
          "Not what you're looking for?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            color: theme.data.foreground100,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          "With hundreds of wallets out there, there's something for everyone",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            color: theme.data.foreground200,
          ),
        ),
        const SizedBox(height: 8.0),
        Web3ModalButton(
          onPressed: () => launchUrl(
            Uri.parse('https://explorer.walletconnect.com/?type=wallet'),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Explore Wallets',
                style: TextStyle(
                  fontFamily: theme.data.fontFamily,
                  color: theme.data.inverse100,
                ),
              ),
              Icon(
                Icons.arrow_outward,
                size: 12,
                color: theme.data.inverse100,
              ),
            ],
          ),
        ),
        // URL: https://explorer.walletconnect.com/?type=wallet
      ],
    );
  }
}

class WalletItem extends StatelessWidget {
  const WalletItem({
    super.key,
    required this.wallet,
  });

  final GridListItemModel<WalletData> wallet;

  @override
  Widget build(BuildContext context) {
    final Web3ModalTheme theme = Web3ModalTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
      ),
      child: ListTile(
        leading: WalletImage(
          imageUrl: wallet.image,
          imageSize: 50,
        ),
        title: Text(
          wallet.title,
          style: TextStyle(
            fontSize: 16.0,
            color: theme.data.foreground100,
          ),
        ),
        trailing: Web3ModalButton(
          onPressed: () => launchUrl(
            Uri.parse(
              wallet.data.listing.homepage,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get',
                style: TextStyle(
                  fontFamily: theme.data.fontFamily,
                  color: theme.data.inverse100,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: theme.data.inverse100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
