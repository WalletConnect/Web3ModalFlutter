import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_account_orb.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/account_list_item.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar_action_button.dart';
import 'package:web3modal_flutter/widgets/text/w3m_address.dart';
import 'package:web3modal_flutter/widgets/text/w3m_balance.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';

class ApproveTransactionPage extends StatefulWidget {
  const ApproveTransactionPage()
      : super(key: Web3ModalKeyConstants.approveTransactionPage);

  @override
  State<ApproveTransactionPage> createState() => _ApproveTransactionPageState();
}

class _ApproveTransactionPageState extends State<ApproveTransactionPage> {
  IW3MService? _service;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service = Web3ModalProvider.of(context).service;
      _service?.addListener(_rebuild);
      _rebuild();
    });
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _service?.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);

    if (_service == null) {
      return ContentLoading();
    }

    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: kNavbarHeight / 2,
              left: kPadding12,
              right: kPadding12,
              bottom: kPadding12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const W3MAccountOrb(size: 72.0),
                    const SizedBox.square(dimension: kPadding12),
                    W3MAddress(
                      service: _service!,
                      style: themeData.textStyles.large600.copyWith(
                        color: themeColors.foreground100,
                      ),
                    ),
                    const W3MBalanceText(),
                    const SizedBox.square(dimension: kPadding12),
                    Text(
                      'Signature request',
                      style: themeData.textStyles.paragraph600.copyWith(
                        color: themeColors.foreground100,
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: AccountListItem(
                        iconPath: 'assets/icons/close.svg',
                        iconBGColor: themeColors.error100.withOpacity(0.5),
                        iconColor: themeColors.foreground200,
                        iconBorderColor: themeColors.grayGlass010,
                        trailing: const SizedBox.shrink(),
                        title: 'Cancel',
                        titleStyle: themeData.textStyles.paragraph600.copyWith(
                          color: themeColors.foreground200,
                        ),
                        onTap: () async {
                          _service?.closeModal();
                          // await _service?.disconnect();
                        },
                      ),
                    ),
                    const SizedBox.square(dimension: kPadding12),
                    Expanded(
                      child: AccountListItem(
                        iconPath: 'assets/icons/checkmark.svg',
                        iconBGColor: themeColors.success100.withOpacity(0.5),
                        iconColor: themeColors.foreground200,
                        iconBorderColor: themeColors.grayGlass010,
                        trailing: const SizedBox.shrink(),
                        title: 'Approve',
                        onTap: () {
                          _service?.closeModal();
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: NavbarActionButton(
              asset: 'assets/icons/close.svg',
              action: () => _service?.closeModal(),
            ),
          ),
        ],
      ),
    );
  }
}
