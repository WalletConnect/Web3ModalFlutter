import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:web3modal_flutter/pages/get_wallet_page.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';

import 'package:walletconnect_modal_flutter/services/utils/platform/platform_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/services/utils/url/url_utils_singleton.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_button.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar.dart';
import 'package:walletconnect_modal_flutter/widgets/walletconnect_modal_navbar_title.dart';

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

  final _pageController = PageController();

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
    final themeData = Web3ModalTheme.getDataOf(context);

    bool longBottomSheet = platformUtils.instance.isLongBottomSheet(
      MediaQuery.of(context).orientation,
    );

    return WalletConnectModalNavBar(
      title: const WalletConnectModalNavbarTitle(
        title: 'What is a wallet?',
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          longBottomSheet ? _buildPageView() : _buildColumnSection(),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(
              minWidth: 250,
              // maxWidth: 400,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WalletConnectModalButton(
                  key: Web3ModalKeyConstants.getAWalletButtonKey,
                  onPressed: () {
                    widgetStack.instance.add(
                      const GetWalletPage(),
                    );
                  },
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/wallet.svg',
                        width: 18,
                        height: 18,
                        package: 'walletconnect_modal_flutter',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Get a Wallet',
                        style: TextStyle(
                          fontFamily: themeData.textStyles.fontFamily,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                WalletConnectModalButton(
                  onPressed: () {
                    urlUtils.instance.launchUrl(
                      Uri.parse(
                        'https://ethereum.org/en/wallets/',
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Learn More',
                        style: TextStyle(
                          fontFamily: themeData.textStyles.fontFamily,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        size: 18,
                        Icons.arrow_outward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    final List<Widget> pages = _buildSections(
      padding: 0,
    );
    final themeData = Web3ModalTheme.getDataOf(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 160,
          ),
          child: PageView.builder(
            controller: _pageController,
            // itemCount: pages.length,
            itemBuilder: (_, index) {
              return pages[index % pages.length];
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageController,
          count: pages.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            dotColor: themeData.colors.blue080,
            activeDotColor: themeData.colors.blue100,
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildColumnSection() {
    return Column(
      children: _buildSections(),
    );
  }

  List<Widget> _buildSections({
    double padding = 10,
  }) {
    return [
      _buildSection(
        title: 'A home for your digital assets',
        description:
            'A wallet lets you store, send, and receive digital assets like cryptocurrencies and NFTs.',
        images: _images.sublist(0, 3),
        padding: padding,
      ),
      _buildSection(
        title: 'One login for all of web3',
        description:
            'Log in to any app by connecting your wallet. Say goodbye to countless passwords!',
        images: _images.sublist(3, 6),
        padding: padding,
      ),
      _buildSection(
        title: 'Your gateway to a new web',
        description:
            'With your wallet, you can explore and interact with DeFi, NFTs, DAOS, and much more.',
        images: _images.sublist(6, 9),
        padding: padding,
      ),
    ];
  }

  Widget _buildSection({
    required String title,
    required String description,
    required List<Widget> images,
    double padding = 10,
  }) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return Container(
      padding: EdgeInsets.all(padding),
      constraints: const BoxConstraints(
        maxWidth: 600,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeData.colors.foreground100,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: themeData.colors.foreground200,
            ),
          ),
        ],
      ),
    );
  }
}
