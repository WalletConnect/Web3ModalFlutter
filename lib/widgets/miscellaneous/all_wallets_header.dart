import 'package:flutter/material.dart';
import 'package:web3modal_flutter/pages/qr_code_page.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/widgets/icons/themed_icon.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/searchbar.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';

class AllWalletsHeader extends StatelessWidget {
  const AllWalletsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(kPadding8),
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
          ThemedButton(
            size: kSearchFieldHeight,
            iconPath: 'assets/icons/code.svg',
            onPressed: () {
              widgetStack.instance.push(const QRCodePage());
            },
          ),
          const SizedBox.square(dimension: 2.0),
        ],
      ),
    );
  }
}
