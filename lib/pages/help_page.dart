import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/web3modal_button.dart';

class SvgImageInfo {
  final String path;
  final double? radius;

  SvgImageInfo({
    required this.path,
    this.radius,
  });
}

class HelpPage extends StatefulWidget {
  const HelpPage({
    super.key,
    required this.getAWallet,
  });

  final void Function() getAWallet;

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
            package: 'web3modal_flutter',
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Web3ModalTheme theme = Web3ModalTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildSection(
          title: 'A home for your digital assets',
          description:
              'A wallet lets you store, send, and receive digital assets like cryptocurrencies and NFTs.',
          images: _images.sublist(0, 3),
        ),
        buildSection(
          title: 'One login for all of web3',
          description:
              'Log in to any app by connecting your wallet. Say goodbye to countless passwords!',
          images: _images.sublist(3, 6),
        ),
        buildSection(
          title: 'Your gateway to a new web',
          description:
              'With your wallet, you can explore and interact with DeFi, NFTs, DAOS, and much more.',
          images: _images.sublist(6, 9),
        ),
        Container(
          constraints: const BoxConstraints(
            minWidth: 250,
            maxWidth: 350,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Web3ModalButton(
                  onPressed: widget.getAWallet,
                  child: Text(
                    'Get a Wallet',
                    style: TextStyle(
                      fontFamily: theme.data.fontFamily,
                      color: theme.data.inverse100,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Web3ModalButton(
                  onPressed: () {
                    launchUrl(
                      Uri.parse(
                        'https://ethereum.org/en/wallets/',
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Learn More',
                        style: TextStyle(
                          fontFamily: theme.data.fontFamily,
                          color: theme.data.inverse100,
                        ),
                      ),
                      Icon(
                        Icons.arrow_outward,
                        color: theme.data.inverse100,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSection({
    required String title,
    required String description,
    required List<Widget> images,
    List<double?> imageBorderRadius = const [],
  }) {
    Web3ModalTheme theme = Web3ModalTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.data.foreground100,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: theme.data.foreground200,
            ),
          ),
        ],
      ),
    );
  }
}
