import 'package:flutter/material.dart';

import 'package:web3modal_flutter/pages/get_wallet_page.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';
import 'package:web3modal_flutter/widgets/help/help_section.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class AboutWallets extends StatelessWidget {
  const AboutWallets() : super(key: Web3ModalKeyConstants.helpPageKey);

  @override
  Widget build(BuildContext context) {
    return Web3ModalNavbar(
      title: 'What is a wallet?',
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Column(
              children: [
                HelpSection(
                  title: 'One login for all of web3',
                  description:
                      'Log in to any app by connecting your wallet. Say goodbye to countless passwords!',
                  images: [
                    'assets/help/key.svg',
                    'assets/help/user.svg',
                    'assets/help/lock.svg',
                  ],
                ),
                HelpSection(
                  title: 'A home for your digital assets',
                  description:
                      'A wallet lets you store, send, and receive digital assets like cryptocurrencies and NFTs.',
                  images: [
                    'assets/help/chart.svg',
                    'assets/help/painting.svg',
                    'assets/help/eth.svg',
                  ],
                ),
                HelpSection(
                  title: 'Your gateway to a new web',
                  description:
                      'With your wallet, you can explore and interact with DeFi, NFTs, DAOS, and much more.',
                  images: [
                    'assets/help/compass.svg',
                    'assets/help/noun.svg',
                    'assets/help/dao.svg',
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SimpleIconButton(
              onTap: () {
                widgetStack.instance.push(const GetWalletPage());
              },
              leftIcon: 'assets/icons/wallet.svg',
              title: 'Get a wallet',
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
