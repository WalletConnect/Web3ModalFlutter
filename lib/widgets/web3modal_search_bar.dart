import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/web3modal_theme.dart';

class Web3ModalSearchBar extends StatelessWidget {
  const Web3ModalSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
  });

  final String hintText;
  final void Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    final Web3ModalTheme theme = Web3ModalTheme.of(context);

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.accentColor,
        borderRadius: BorderRadius.circular(
          30.0,
        ),
        border: Border.all(
          color: theme.accentColor.withOpacity(0.7),
          width: 2,
        ),
      ),
      child: TextFormField(
        onChanged: onSearch,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          border: InputBorder.none,
          isCollapsed: true,
          // contentPadding: const EdgeInsets.symmetric(vertical: 2.0),
        ),
      ),
    );
  }
}
