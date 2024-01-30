import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service.dart';

import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/searchbar.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';

class ConfirmEmailPage extends StatefulWidget {
  const ConfirmEmailPage() : super(key: Web3ModalKeyConstants.confirmEmailPage);

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  static const _emptyString = ' ';
  final List<FocusNode> _focusNodes = [
    FocusNode(debugLabel: 'focus0'),
    FocusNode(debugLabel: 'focus1'),
    FocusNode(debugLabel: 'focus2'),
    FocusNode(debugLabel: 'focus3'),
    FocusNode(debugLabel: 'focus4'),
    FocusNode(debugLabel: 'focus5'),
  ];

  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final Map<int, String> _digit = {
    0: _emptyString,
    1: _emptyString,
    2: _emptyString,
    3: _emptyString,
    4: _emptyString,
    5: _emptyString,
  };

  @override
  void initState() {
    super.initState();
    _focusNodes.first.requestFocus();
    for (var fn in _focusNodes) {
      fn.addListener(_focusListener);
    }
  }

  @override
  void dispose() {
    for (var fn in _focusNodes) {
      fn.removeListener(_focusListener);
    }
    super.dispose();
  }

  void _focusListener() {
    int? emptyIndex = _digit.entries.firstWhereOrNull((e) {
      return e.value.trim().isEmpty;
    })?.key;
    final firstEmptyIndex = emptyIndex ?? -1;
    final focusedIndex = _focusNodes.indexWhere((fn) => fn.hasFocus);
    //
    for (var entry in _digit.entries) {
      if (entry.key >= focusedIndex) {
        _digit[entry.key] = _emptyString;
        _controllers[entry.key].text = _emptyString;
      }
    }
    if (focusedIndex > firstEmptyIndex && firstEmptyIndex >= 0) {
      _focusNodes[firstEmptyIndex].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final textStyles = Web3ModalTheme.getDataOf(context).textStyles;
    return Web3ModalNavbar(
      title: 'Confirm Email',
      safeAreaLeft: true,
      safeAreaRight: true,
      onBack: () {
        FocusManager.instance.primaryFocus?.unfocus();
        magicService.instance.setEmail('');
        widgetStack.instance.pop();
      },
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: kPadding8,
              horizontal: kPadding12,
            ),
            child: Column(
              children: [
                const SizedBox.square(dimension: kPadding16),
                Text(
                  'Enter the code we sent to ',
                  textAlign: TextAlign.center,
                  style: textStyles.paragraph400.copyWith(
                    color: themeColors.foreground100,
                  ),
                ),
                Text(
                  magicService.instance.email.value,
                  textAlign: TextAlign.center,
                  style: textStyles.paragraph500.copyWith(
                    color: themeColors.foreground100,
                  ),
                ),
                const SizedBox.square(dimension: kPadding12),
                Text(
                  'The code expires in 10 minutes',
                  style: textStyles.small400.copyWith(
                    color: themeColors.foreground200,
                  ),
                ),
                const SizedBox.square(dimension: kPadding16),
                ValueListenableBuilder<bool>(
                  valueListenable: magicService.instance.waitConfirmation,
                  builder: (context, waiting, _) {
                    if (waiting) {
                      return SizedBox(
                        width: kSearchFieldHeight + 8.0,
                        height: kSearchFieldHeight + 8.0,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                              color: themeColors.accent100,
                            ),
                          ),
                        ),
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _focusNodes
                          .mapIndexed(
                            (index, fn) => Web3ModalSearchBar(
                              width: kSearchFieldHeight + 8.0,
                              initialValue: _digit[index]!,
                              controller: _controllers[index],
                              focusNode: fn,
                              textInputType: TextInputType.number,
                              textAlign: TextAlign.center,
                              showCursor: false,
                              debounce: false,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2),
                              ],
                              textStyle: textStyles.large400.copyWith(
                                color: themeColors.foreground100,
                              ),
                              prefixIcon: const SizedBox.shrink(),
                              suffixIcon: const SizedBox.shrink(),
                              noIcons: true,
                              onTextChanged: (value) {
                                _onTextChanged(index, value, fn);
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox.square(dimension: kPadding12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didn\'t receive it?',
                      style: textStyles.small400.copyWith(
                        color: themeColors.foreground200,
                      ),
                    ),
                    const SizedBox.square(dimension: kPadding6),
                    GestureDetector(
                      onTap: () {
                        final email = magicService.instance.email.value;
                        magicService.instance.connectEmail(email: email);
                      },
                      child: Text(
                        'Resend code',
                        style: textStyles.small600.copyWith(
                          color: themeColors.accent100,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTextChanged(int index, String value, FocusNode node) {
    _digit[index] = value.trim();
    if (_digit[index]!.isNotEmpty) {
      if (index == 5) {
        final code = _digit.values.join();
        magicService.instance.connectOtp(otp: code);
      } else {
        node.nextFocus();
      }
    } else {
      if (_digit[index]!.isEmpty) {
        _digit[index] = _emptyString;
      }
      if (index > 0) {
        node.previousFocus();
      }
    }
  }
}
