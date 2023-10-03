import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

class HelpSection extends StatelessWidget {
  const HelpSection({
    super.key,
    required this.title,
    required this.description,
    required this.images,
  });
  final String title, description;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Container(
      padding: const EdgeInsets.all(kPadding12),
      child: Column(
        children: <Widget>[
          const SizedBox.square(dimension: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images
                .map(
                  (path) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: SvgPicture.asset(
                      path,
                      package: 'web3modal_flutter',
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox.square(dimension: kPadding12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: themeData.textStyles.paragraph500.copyWith(
              color: themeColors.foreground100,
            ),
          ),
          const SizedBox.square(dimension: 8.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: themeData.textStyles.small500.copyWith(
              color: themeColors.foreground200,
            ),
          ),
        ],
      ),
    );
  }
}
