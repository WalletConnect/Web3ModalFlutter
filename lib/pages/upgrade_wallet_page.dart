import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/analytics_service/analytics_service_singleton.dart';
import 'package:web3modal_flutter/services/analytics_service/models/analytics_event.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class UpgradeWalletPage extends StatelessWidget {
  const UpgradeWalletPage() : super(key: KeyConstants.upgradeWalletPage);

  @override
  Widget build(BuildContext context) {
    final textStyles = Web3ModalTheme.getDataOf(context).textStyles;
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Web3ModalNavbar(
      title: 'Upgrade your Wallet',
      safeAreaBottom: true,
      safeAreaLeft: true,
      safeAreaRight: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox.square(dimension: kPadding8),
          const SizedBox.square(dimension: kPadding8),
          Text(
            'Follow the instructions on',
            style: textStyles.paragraph500.copyWith(
              color: themeColors.foreground100,
            ),
          ),
          const SizedBox.square(dimension: kPadding8),
          SimpleIconButton(
            leftIcon: 'assets/icons/wc.svg',
            onTap: () {
              analyticsService.instance.sendEvent(EmailUpgradeFromModal());
              launchUrlString(
                StringConstants.secureSite,
                mode: LaunchMode.externalApplication,
              );
            },
            rightIcon: 'assets/icons/arrow_top_right.svg',
            title: 'secure.walletconnect.com',
            size: BaseButtonSize.small,
            iconSize: 12.0,
            fontSize: 14.0,
          ),
          const SizedBox.square(dimension: kPadding8),
          Text(
            'You will have to reconnect for security reasons',
            style: textStyles.small400.copyWith(
              color: themeColors.foreground200,
            ),
          ),
          const SizedBox.square(dimension: kPadding8),
        ],
      ),
    );
  }
}
