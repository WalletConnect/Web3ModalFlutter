import 'package:flutter/material.dart';
import 'package:web3modal_flutter/models/listings.dart';

class GetWalletPage extends StatelessWidget {
  final List<WalletData> recommendedWallets;
  final List<WalletData> manualWallets;

  const GetWalletPage({
    super.key,
    required this.recommendedWallets,
    required this.manualWallets,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Get a wallet'),
        ListView(
          children: [
            ...recommendedWallets
                .map((wallet) => WalletItem(wallet: wallet))
                .toList(),
            ...manualWallets
                .map((wallet) => WalletItem(wallet: wallet))
                .toList(),
          ],
        ),
        const Text('Explore Wallets'),
        // URL: https://explorer.walletconnect.com/?type=wallet
      ],
    );
  }
}

class WalletItem extends StatelessWidget {
  final WalletData wallet;

  const WalletItem({
    super.key,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          Icon(Icons.wallet_giftcard), // replace with your own image widget
      title: Text(wallet.name),
      trailing: IconButton(
        icon: Icon(Icons.arrow_forward),
        onPressed: () {
          // Open the wallet's link in a new tab
          // This requires the url_launcher package
          // You can handle the link based on whether it's a 'universal' or 'native' link
          String? url = wallet.universal;
          if (wallet.native != null) {
            url = wallet.native!;
          }
          // launch(url);
        },
      ),
    );
  }
}
