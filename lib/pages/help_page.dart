import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:web3modal_flutter/pages/get_wallet_page.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/widgets/buttons/simple_icon_button.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class SvgImageInfo {
  final String path;
  final double? radius;

  SvgImageInfo({
    required this.path,
    this.radius,
  });
}

class HelpPage extends StatefulWidget {
  const HelpPage() : super(key: Web3ModalKeyConstants.helpPageKey);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<SvgImageInfo> _imageInfos = [
    SvgImageInfo(
      path: 'assets/help_page/help_chart.svg',
    ),
    SvgImageInfo(
      path: 'assets/help_page/help_painting.svg',
    ),
    SvgImageInfo(
      path: 'assets/help_page/help_eth.svg',
    ),
    SvgImageInfo(
      path: 'assets/help_page/help_key.svg',
    ),
    SvgImageInfo(
      path: 'assets/help_page/help_user.svg',
      radius: 50,
    ),
    SvgImageInfo(
      path: 'assets/help_page/help_lock.svg',
    ),
    SvgImageInfo(
      path: 'assets/help_page/help_compass.svg',
    ),
    SvgImageInfo(
      path: 'assets/help_page/help_noun.svg',
    ),
    SvgImageInfo(
      path: 'assets/help_page/help_dao.svg',
    ),
  ];
  List<Widget> _images = [];

  @override
  void initState() {
    super.initState();

    _images = _imageInfos.map((e) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 4.0,
          right: 4.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              e.radius ?? 0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: SvgPicture.asset(
            e.path,
            package: 'walletconnect_modal_flutter',
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Web3ModalNavbar(
      title: 'What is a wallet?',
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  children: [
                    _HelpSection(
                      title: 'One login for all of web3',
                      description:
                          'Log in to any app by connecting your wallet. Say goodbye to countless passwords!',
                      images: _images.sublist(3, 6),
                    ),
                    _HelpSection(
                      title: 'A home for your digital assets',
                      description:
                          'A wallet lets you store, send, and receive digital assets like cryptocurrencies and NFTs.',
                      images: _images.sublist(0, 3),
                    ),
                    _HelpSection(
                      title: 'Your gateway to a new web',
                      description:
                          'With your wallet, you can explore and interact with DeFi, NFTs, DAOS, and much more.',
                      images: _images.sublist(6, 9),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SimpleIconButton(
                  onTap: () {
                    widgetStack.instance.add(const GetWalletPage());
                  },
                  svgIcon: 'assets/icons/wallet.svg',
                  title: 'Get a wallet',
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({
    required this.title,
    required this.description,
    required this.images,
  });
  final String title, description;
  final List<Widget> images;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    return Container(
      padding: const EdgeInsets.all(kPadding12),
      child: Column(
        children: <Widget>[
          const SizedBox.square(dimension: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images,
          ),
          const SizedBox.square(dimension: kPadding12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: themeData.textStyles.paragraph500.copyWith(
              color: themeData.colors.foreground100,
            ),
          ),
          const SizedBox.square(dimension: 8.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: themeData.textStyles.small500.copyWith(
              color: themeData.colors.foreground200,
            ),
          ),
        ],
      ),
    );
  }
}
