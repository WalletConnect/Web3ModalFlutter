import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/web3modal_theme.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_account_avatar.dart';

class W3MAccountOrb extends StatelessWidget {
  const W3MAccountOrb({super.key, this.size = 70.0});
  final double size;

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final service = Web3ModalProvider.of(context).service;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: themeData.colors.overgray005,
          width: 8.0,
        ),
      ),
      child: W3MAccountAvatar(
        service: service,
        size: size - 8.0,
      ),
    );
  }
}
