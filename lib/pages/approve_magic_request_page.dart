import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service.dart';
// import 'package:web3modal_flutter/widgets/miscellaneous/responsive_container.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';
// import 'package:web3modal_flutter/widgets/navigation/navbar_action_button.dart';
// import 'package:web3modal_flutter/widgets/web3modal_provider.dart';

class ApproveTransactionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final service = Web3ModalProvider.of(context).service;
    // final isPortrait = ResponsiveData.isPortrait(context);
    return Web3ModalNavbar(
      title: 'Approve Transaction',
      noClose: true,
      safeAreaLeft: true,
      safeAreaRight: true,
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          child: SizedBox(
            width: 1.0,
            height: 1.0,
            child: magicService.instance.webview,
          ),
        ),
      ),
    );
  }
}
