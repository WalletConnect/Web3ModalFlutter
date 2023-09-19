import 'package:flutter/material.dart';
import 'package:web3modal_flutter/theme/theme.dart';

class Web3ModalSearchBar extends StatefulWidget {
  const Web3ModalSearchBar({
    super.key,
    required this.onTextChanged,
    this.hint = '',
  });
  final Function(String) onTextChanged;
  final String hint;

  @override
  State<Web3ModalSearchBar> createState() => _Web3ModalSearchBarState();
}

class _Web3ModalSearchBarState extends State<Web3ModalSearchBar> {
  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius2XS),
        border: Border.all(
          color: themeData.colors.overgray015,
          width: 1.0,
        ),
      ),
      child: TextFormField(
        onChanged: widget.onTextChanged,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          color: themeData.colors.foreground100,
        ),
        cursorColor: themeData.colors.blue100,
        // cursorHeight: 20,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: themeData.colors.foreground275,
          ),
          labelStyle: TextStyle(
            color: themeData.colors.inverse000,
          ),
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: themeData.colors.foreground275,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(kRadius2XS),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: themeData.colors.blue100,
            ),
            borderRadius: BorderRadius.circular(kRadius2XS),
          ),
          filled: true,
          fillColor: themeData.colors.background200,
          contentPadding: const EdgeInsets.all(0.0),
        ),
      ),
    );
  }
}
