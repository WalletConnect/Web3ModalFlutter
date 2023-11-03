import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:web3modal_flutter/pages/qr_code_page.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/searchbar.dart';

class AllWalletsHeader extends StatelessWidget {
  const AllWalletsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(
        left: kPadding8,
        top: kPadding8,
        bottom: kPadding8,
        right: kPadding12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Web3ModalSearchBar(
              hint: 'Search wallet',
              onTextChanged: (value) {
                explorerService.instance!.search(query: value);
              },
              onDismissKeyboard: (clear) {
                FocusManager.instance.primaryFocus?.unfocus();
                if (clear) {
                  explorerService.instance!.search(query: null);
                }
              },
            ),
          ),
          const SizedBox.square(dimension: kPadding8),
          GestureDetector(
            onTap: () {
              widgetStack.instance.push(const QRCodePage());
            },
            child: SvgPicture.asset(
              AssetUtil.getThemedAsset(context, 'code_button.svg'),
              package: 'web3modal_flutter',
              height: kSearchFieldHeight,
              width: kSearchFieldHeight,
            ),
          ),
        ],
      ),
    );
  }
}
