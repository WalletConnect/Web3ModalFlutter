import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/constants.dart';

class AccountPage extends StatelessWidget {
  const AccountPage()
      : super(
          key: Web3ModalConstants.accountPage,
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: const Center(
        child: Text('Account Page'),
      ),
    );
  }
}
