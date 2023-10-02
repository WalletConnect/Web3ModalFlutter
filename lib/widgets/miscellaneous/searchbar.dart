import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

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
    final unfocusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: themeData.colors.overgray015, width: 1.0),
      borderRadius: BorderRadius.circular(kRadius2XS),
    );
    final focusedBorder = unfocusedBorder.copyWith(
      borderSide: BorderSide(color: themeData.colors.blue100, width: 1.0),
    );
    return SizedBox(
      height: kSearchFieldHeight,
      child: TextFormField(
        onChanged: widget.onTextChanged,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          color: themeData.colors.foreground100,
          height: 1.5,
        ),
        cursorColor: themeData.colors.blue100,
        cursorHeight: 20.0,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: Center(
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              package: 'web3modal_flutter',
              colorFilter: ColorFilter.mode(
                themeData.colors.foreground275,
                BlendMode.srcIn,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            maxHeight: kSearchFieldHeight,
            minHeight: kSearchFieldHeight,
            maxWidth: kSearchFieldHeight,
            minWidth: kSearchFieldHeight,
          ),
          labelStyle: themeData.textStyles.paragraph500.copyWith(
            color: themeData.colors.inverse100,
          ),
          hintText: widget.hint,
          hintStyle: themeData.textStyles.paragraph500.copyWith(
            color: themeData.colors.foreground275,
            height: 1.5,
          ),
          border: unfocusedBorder,
          errorBorder: unfocusedBorder,
          enabledBorder: unfocusedBorder,
          disabledBorder: unfocusedBorder,
          focusedBorder: focusedBorder,
          filled: true,
          fillColor: themeData.colors.overgray005,
          contentPadding: const EdgeInsets.all(0.0),
        ),
      ),
    );
  }
}
