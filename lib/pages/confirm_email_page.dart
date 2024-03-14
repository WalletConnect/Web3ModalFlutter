import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/magic_service/i_magic_service.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_events.dart';

import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/toast/toast_message.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils_singleton.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/searchbar.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';

class ConfirmEmailPage extends StatefulWidget {
  const ConfirmEmailPage() : super(key: KeyConstants.confirmEmailPage);

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  @override
  void initState() {
    super.initState();
    magicService.instance.onMagicError.subscribe(_onMagicErrorEvent);
  }

  @override
  void dispose() {
    magicService.instance.onMagicError.unsubscribe(_onMagicErrorEvent);
    super.dispose();
  }

  void _onMagicErrorEvent(MagicErrorEvent? event) {
    toastUtils.instance.show(ToastMessage(
      type: ToastType.error,
      text: event?.error ?? 'Something went wrong.',
    ));
    if (event is ConnectEmailErrorEvent) {
      _goBack();
    } else {
      setState(() {});
    }
  }

  void _goBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    magicService.instance.setEmail('');
    widgetStack.instance.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EmailLoginStep>(
      valueListenable: magicService.instance.step,
      builder: (context, action, _) {
        final title = (action == EmailLoginStep.verifyDevice)
            ? 'Register device'
            : 'Confirm Email';
        return Web3ModalNavbar(
          title: title,
          safeAreaLeft: true,
          safeAreaRight: true,
          onBack: _goBack,
          body: Builder(
            builder: (_) {
              if (action == EmailLoginStep.verifyDevice) {
                return _VerifyDeviceView();
              }
              if (action == EmailLoginStep.verifyOtp) {
                return _VerifyOtpView();
              }
              return ContentLoading(viewHeight: 200.0);
            },
          ),
        );
      },
    );
  }
}

class _VerifyOtpView extends StatefulWidget {
  @override
  State<_VerifyOtpView> createState() => __VerifyOtpViewState();
}

class __VerifyOtpViewState extends State<_VerifyOtpView>
    with WidgetsBindingObserver {
  late DateTime _resendEnabledAt;
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
    WidgetsBinding.instance.addObserver(this);
    _resendEnabledAt = DateTime.now().add(Duration(seconds: 30));
    _focusNodes.first.requestFocus();
    for (var fn in _focusNodes) {
      fn.addListener(_focusListener);
    }
  }

  void _resendEmail() async {
    final diff = DateTime.now().difference(_resendEnabledAt).inSeconds;
    if (diff < 0) {
      toastUtils.instance.show(ToastMessage(
        type: ToastType.error,
        text: 'Try again after ${diff.abs()} seconds',
      ));
    } else {
      final email = magicService.instance.email.value;
      await magicService.instance.connectEmail(value: email);
      _resendEnabledAt = DateTime.now().add(Duration(seconds: 30));
      toastUtils.instance.show(ToastMessage(
        type: ToastType.success,
        text: 'Code email resent',
      ));
    }
  }

  @override
  void dispose() {
    for (var fn in _focusNodes) {
      fn.removeListener(_focusListener);
    }
    WidgetsBinding.instance.removeObserver(this);
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
    return Column(
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
                'The code expires in 20 minutes',
                style: textStyles.small400.copyWith(
                  color: themeColors.foreground200,
                ),
              ),
              const SizedBox.square(dimension: kPadding16),
              Row(
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
              ),
              const SizedBox.square(dimension: kPadding16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive it?',
                    style: textStyles.small400.copyWith(
                      color: themeColors.foreground200,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _resendEmail();
                    },
                    child: Text(
                      'Resend code',
                      style: textStyles.small600.copyWith(
                        color: themeColors.accent100,
                      ),
                    ),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all<Color>(
                        themeColors.accenGlass010,
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final clipboardHasData = await Clipboard.hasStrings();
      if (clipboardHasData) {
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        final code = clipboardData?.text ?? '';
        if (code.isNotEmpty) {
          magicService.instance.connectOtp(otp: code);
        }
      }
    }
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

class _VerifyDeviceView extends StatefulWidget {
  @override
  State<_VerifyDeviceView> createState() => __VerifyDeviceViewState();
}

class __VerifyDeviceViewState extends State<_VerifyDeviceView> {
  late DateTime _resendEnabledAt;

  @override
  void initState() {
    super.initState();
    _resendEnabledAt = DateTime.now().add(Duration(seconds: 30));
  }

  void _resendEmail() async {
    final diff = DateTime.now().difference(_resendEnabledAt).inSeconds;
    if (diff < 0) {
      toastUtils.instance.show(ToastMessage(
        type: ToastType.error,
        text: 'Try again after ${diff.abs()} seconds',
      ));
    } else {
      final email = magicService.instance.email.value;
      await magicService.instance.connectEmail(value: email);
      _resendEnabledAt = DateTime.now().add(Duration(seconds: 30));
      toastUtils.instance.show(ToastMessage(
        type: ToastType.success,
        text: 'Link email resent',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final textStyles = Web3ModalTheme.getDataOf(context).textStyles;
    return Column(
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
              RoundedIcon(
                assetPath: 'assets/icons/verif.svg',
                assetColor: themeColors.accent100,
                circleColor: themeColors.accent100.withOpacity(0.15),
                borderColor: Colors.transparent,
                padding: 22.0,
                size: 70.0,
                borderRadius: 20.0,
              ),
              const SizedBox.square(dimension: kPadding16),
              Text(
                'Approve the login link we sent to ',
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
                'The code expires in 20 minutes',
                style: textStyles.small400.copyWith(
                  color: themeColors.foreground200,
                ),
              ),
              const SizedBox.square(dimension: kPadding16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive it?',
                    style: textStyles.small400.copyWith(
                      color: themeColors.foreground200,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _resendEmail();
                    },
                    child: Text(
                      'Resend email',
                      style: textStyles.small600.copyWith(
                        color: themeColors.accent100,
                      ),
                    ),
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all<Color>(
                        themeColors.accenGlass010,
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
