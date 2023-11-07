import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';
import 'package:web3modal_flutter/widgets/help/help_section.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class AboutNetworks extends StatelessWidget {
  const AboutNetworks() : super(key: Web3ModalKeyConstants.helpPageKey);

  @override
  Widget build(BuildContext context) {
    return Web3ModalNavbar(
      title: 'What is a network?',
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Column(
              children: [
                HelpSection(
                  title: 'The system’s nuts and bolts',
                  description:
                      'A network is what brings the blockchain to life, as this technical infrastructure allows apps to access the ledger and smart contract services.',
                  images: [
                    'assets/help/network.svg',
                    'assets/help/layers.svg',
                    'assets/help/system.svg',
                  ],
                ),
                HelpSection(
                  title: 'Designed for different uses',
                  description:
                      'Each network is designed differently, and may therefore suit certain apps and experiences.',
                  images: [
                    'assets/help/noun.svg',
                    'assets/help/defi.svg',
                    'assets/help/dao.svg',
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SimpleIconButton(
              onTap: () => launchUrlString(
                StringConstants.learnMoreUrl,
                mode: LaunchMode.externalApplication,
              ),
              rightIcon: 'assets/icons/arrow_top_right.svg',
              title: 'Learn more',
              size: BaseButtonSize.small,
              iconSize: 12.0,
              fontSize: 14.0,
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
