import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:web3modal_flutter/constants/key_constants.dart';
import 'package:web3modal_flutter/services/analytics_service/analytics_service_singleton.dart';
import 'package:web3modal_flutter/services/analytics_service/models/analytics_event.dart';
import 'package:web3modal_flutter/services/siwe_service/siwe_service_singleton.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/constants.dart';
import 'package:web3modal_flutter/utils/toast/toast_message.dart';
import 'package:web3modal_flutter/utils/toast/toast_utils_singleton.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_account_avatar.dart';
import 'package:web3modal_flutter/widgets/buttons/primary_button.dart';
import 'package:web3modal_flutter/widgets/buttons/secondary_button.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';
import 'package:web3modal_flutter/widgets/miscellaneous/content_loading.dart';
import 'package:web3modal_flutter/widgets/web3modal_provider.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_wallet_avatar.dart';
import 'package:web3modal_flutter/widgets/navigation/navbar.dart';

class ApproveSIWEPage extends StatefulWidget {
  final Function(W3MSession session) onSiweFinish;
  const ApproveSIWEPage({
    required this.onSiweFinish,
  }) : super(key: KeyConstants.approveSiwePageKey);

  @override
  State<ApproveSIWEPage> createState() => _ApproveSIWEPageState();
}

class _ApproveSIWEPageState extends State<ApproveSIWEPage> {
  IW3MService? _service;
  double _position = 0.0;
  static const _duration = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _position = (MediaQuery.of(context).size.width / 2) + 8.0;
        _service = Web3ModalProvider.of(context).service;
        Future.delayed(Duration(milliseconds: 200), () {
          _animate();
        });
      });
    });
  }

  void _animate() {
    if (!mounted) return;
    setState(() {
      if (_position == (MediaQuery.of(context).size.width / 2) - 12.0) {
        _position = (MediaQuery.of(context).size.width / 2) + 8.0;
      } else {
        _position = (MediaQuery.of(context).size.width / 2) - 12.0;
      }
    });
    Future.delayed(_duration, _animate);
  }

  bool _waitingSign = false;
  void _signIn() async {
    setState(() => _waitingSign = true);
    try {
      final address = _service!.session!.address!;
      String chainId = _service!.selectedChain?.chainId ?? '1';
      analyticsService.instance.sendEvent(ClickSignSiweMessage(
        network: chainId,
      ));
      chainId = W3MChainPresets.chains[chainId]!.namespace;
      //
      final message = await siweService.instance!.createMessage(
        chainId: chainId,
        address: address,
      );
      //
      _service!.launchConnectedWallet();
      final signature = await siweService.instance!.signMessageRequest(
        message,
        session: _service!.session!,
      );
      //
      final clientId = await _service!.web3App!.core.crypto.getClientId();
      await siweService.instance!.verifyMessage(
        message: message,
        signature: signature,
        clientId: clientId,
      );
      //
      final siweSession = await siweService.instance!.getSession();
      final newSession = _service!.session!.copyWith(siweSession: siweSession);
      //
      widget.onSiweFinish(newSession);
      //
    } on JsonRpcError catch (e) {
      _handleError(e.message);
    } on W3MServiceException catch (e) {
      _handleError(e.message);
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _handleError(String? error) {
    debugPrint('[$runtimeType] _handleError $error');
    String chainId = _service!.selectedChain?.chainId ?? '1';
    analyticsService.instance.sendEvent(SiweAuthError(network: chainId));
    toastUtils.instance.show(ToastMessage(
      type: ToastType.error,
      text: error ?? 'Something went wrong.',
    ));
    if (!mounted) return;
    setState(() => _waitingSign = false);
  }

  void _cancelSIWE() async {
    _service?.closeModal(disconnectSession: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_service == null) return ContentLoading();

    final themeData = Web3ModalTheme.getDataOf(context);
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    String peerIcon;
    try {
      peerIcon = _service?.session?.peer?.metadata.icons.first ?? '';
    } catch (e) {
      peerIcon = '';
    }
    String selfIcon;
    try {
      selfIcon = _service?.session?.self?.metadata.icons.first ?? '';
    } catch (e) {
      selfIcon = '';
    }
    return Web3ModalNavbar(
      title: 'Sign In',
      noClose: true,
      safeAreaLeft: true,
      safeAreaRight: true,
      safeAreaBottom: true,
      onBack: _cancelSIWE,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(dimension: kPadding12),
          const SizedBox.square(dimension: kPadding8),
          SizedBox(
            height: 76.0,
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                AnimatedPositioned(
                  duration: _duration,
                  curve: Curves.easeInOut,
                  top: 0,
                  left: _position,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: _service!.session!.sessionService.isMagic ||
                              peerIcon.isEmpty
                          ? BorderRadius.circular(60.0)
                          : BorderRadius.circular(radiuses.radiusM),
                      color: themeColors.background150,
                    ),
                    child: _service!.session!.sessionService.isMagic
                        ? W3MAccountAvatar(
                            service: _service!,
                            size: 60.0,
                          )
                        : SizedBox(
                            width: 60.0,
                            height: 60.0,
                            child: peerIcon.isEmpty
                                ? RoundedIcon(
                                    borderRadius:
                                        radiuses.isSquare() ? 0.0 : 60.0,
                                    size: 60.0,
                                    padding: 12.0,
                                    assetPath:
                                        'assets/icons/regular/wallet.svg',
                                    assetColor: themeColors.accent100,
                                    circleColor: themeColors.accenGlass010,
                                    borderColor: themeColors.accenGlass010,
                                  )
                                : W3MListAvatar(
                                    imageUrl: peerIcon,
                                    borderRadius: radiuses.radiusS,
                                  ),
                          ),
                  ),
                ),
                AnimatedPositioned(
                  duration: _duration,
                  curve: Curves.easeInOut,
                  top: 0,
                  right: _position,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36.0),
                      color: themeColors.background150,
                    ),
                    child: selfIcon.isEmpty
                        ? W3MAccountAvatar(
                            service: _service!,
                            size: 60.0,
                          )
                        : SizedBox(
                            width: 60.0,
                            height: 60.0,
                            child: W3MListAvatar(
                              imageUrl: selfIcon,
                              borderRadius: 30.0,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox.square(dimension: kPadding12),
          const SizedBox.square(dimension: kPadding8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: Text(
              '${_service!.web3App!.metadata.name} needs to connect to your wallet',
              textAlign: TextAlign.center,
              style: themeData.textStyles.paragraph400.copyWith(
                color: themeColors.foreground100,
              ),
            ),
          ),
          const SizedBox.square(dimension: kPadding12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              'Sign this message to prove you own this wallet and proceed. Canceling will disconnect you.',
              textAlign: TextAlign.center,
              style: themeData.textStyles.small400.copyWith(
                color: themeColors.foreground200,
              ),
            ),
          ),
          const SizedBox.square(dimension: kPadding12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPadding12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox.square(dimension: 4.0),
                Expanded(
                  child: SecondaryButton(
                    title: 'Cancel',
                    onTap: _cancelSIWE,
                  ),
                ),
                const SizedBox.square(dimension: kPadding8),
                Expanded(
                  child: PrimaryButton(
                    title: 'Sign',
                    onTap: _signIn,
                    loading: _waitingSign,
                  ),
                ),
                const SizedBox.square(dimension: 4.0),
              ],
            ),
          ),
          const SizedBox.square(dimension: kPadding8),
        ],
      ),
    );
  }
}
