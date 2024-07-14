import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/magic_service/models/email_login_step.dart';
import 'package:web3modal_flutter/services/magic_service/magic_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_events.dart';

import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/toast/toast_message.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils_singleton.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/verify_otp_view.dart';
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
    magicService.instance.step.value = EmailLoginStep.idle;
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
    magicService.instance.step.value = EmailLoginStep.idle;
    magicService.instance.setEmail('');
    FocusManager.instance.primaryFocus?.unfocus();
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
                return VerifyOtpView(
                  currentEmail: magicService.instance.email.value,
                  resendEmail: magicService.instance.connectEmail,
                  verifyOtp: magicService.instance.connectOtp,
                );
              }
              return ContentLoading(viewHeight: 200.0);
            },
          ),
        );
      },
    );
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
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final borderRadiusIcon = radiuses.isSquare() ? 0.0 : 20.0;
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
                borderRadius: borderRadiusIcon,
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
                'The link expires in 20 minutes',
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
