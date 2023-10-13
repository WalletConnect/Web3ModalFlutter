import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';

class Web3ModalSearchBar extends StatefulWidget {
  const Web3ModalSearchBar({
    super.key,
    required this.onTextChanged,
    this.onDismissKeyboard,
    this.hint = '',
  });
  final Function(String) onTextChanged;
  final String hint;
  final Function(bool)? onDismissKeyboard;

  @override
  State<Web3ModalSearchBar> createState() => _Web3ModalSearchBarState();
}

class _Web3ModalSearchBarState extends State<Web3ModalSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _debouncer = _Debouncer(milliseconds: 200);

  @override
  void initState() {
    _controller.addListener(_updateState);
    _focusNode.addListener(_updateState);
    super.initState();
  }

  void _updateState() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _focusNode.removeListener(_updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final unfocusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: themeColors.grayGlass015, width: 1.0),
      borderRadius: BorderRadius.circular(radiuses.radius2XS),
    );
    final focusedBorder = unfocusedBorder.copyWith(
      borderSide: BorderSide(color: themeColors.accent100, width: 1.0),
    );

    return SizedBox(
      height: kSearchFieldHeight,
      child: TextFormField(
        focusNode: _focusNode,
        controller: _controller,
        onChanged: (value) {
          _debouncer.run(() => widget.onTextChanged(value));
        },
        onTapOutside: (_) {
          widget.onDismissKeyboard?.call(false);
        },
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          color: themeColors.foreground100,
          height: 1.5,
        ),
        cursorColor: themeColors.accent100,
        enableSuggestions: false,
        autocorrect: false,
        cursorHeight: 20.0,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: Center(
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              package: 'web3modal_flutter',
              colorFilter: ColorFilter.mode(
                themeColors.foreground275,
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
            color: themeColors.inverse100,
          ),
          hintText: widget.hint,
          hintStyle: themeData.textStyles.paragraph500.copyWith(
            color: themeColors.foreground275,
            height: 1.5,
          ),
          suffixIcon: _controller.value.text.isNotEmpty || _focusNode.hasFocus
              ? IconButton(
                  padding: const EdgeInsets.all(0.0),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    widget.onDismissKeyboard?.call(true);
                  },
                )
              : null,
          border: unfocusedBorder,
          errorBorder: unfocusedBorder,
          enabledBorder: unfocusedBorder,
          disabledBorder: unfocusedBorder,
          focusedBorder: focusedBorder,
          filled: true,
          fillColor: themeColors.grayGlass005,
          contentPadding: const EdgeInsets.all(0.0),
        ),
      ),
    );
  }
}

class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
