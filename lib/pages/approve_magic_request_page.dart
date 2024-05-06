import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service_singleton.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class ApproveTransactionPage extends StatefulWidget {
  const ApproveTransactionPage()
      : super(key: KeyConstants.approveTransactionPage);

  @override
  State<ApproveTransactionPage> createState() => _ApproveTransactionPageState();
}

class _ApproveTransactionPageState extends State<ApproveTransactionPage> {
  @override
  Widget build(BuildContext context) {
    magicService.instance.controller.runJavaScript(
      'document.body.style.zoom = "1%"',
    );
    return Web3ModalNavbar(
      title: 'Approve Transaction',
      noClose: true,
      safeAreaLeft: true,
      safeAreaRight: true,
      body: magicService.instance.webview,
    );
  }
}
