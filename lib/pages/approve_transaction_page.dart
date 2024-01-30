import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';
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
    // final themeData = Web3ModalTheme.getDataOf(context);
    // final themeColors = Web3ModalTheme.colorsOf(context);

    if (_service == null) {
      return ContentLoading();
    }

    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.7,
        child: magicService.instance.webview,
      ),
    );
  }
}
