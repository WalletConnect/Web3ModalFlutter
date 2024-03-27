import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/analytics_service/analytics_service_singleton.dart';
import 'package:web3modal_flutter/services/analytics_service/models/analytics_event.dart';
import 'package:web3modal_flutter/services/logger_service/logger_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/models/email_login_step.dart';
import 'package:web3modal_flutter/services/magic_service/i_magic_service.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_data.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_events.dart';
import 'package:web3modal_flutter/services/magic_service/models/frame_message.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class MagicService implements IMagicService {
  static const _url = 'secure-mobile.walletconnect.com';
  static const _safeDomains = [
    _url,
    'secure.walletconnect.com',
    'auth.magic.link',
    'launchdarkly.com',
    if (kDebugMode) 'ngrok.app',
  ];
  static const supportedMethods = [
    'personal_sign',
    'eth_sign',
    'eth_sendTransaction',
    'eth_signTypedData_v4',
    'wallet_switchEthereumChain',
    'wallet_addEthereumChain',
  ];
  //
  late final GlobalKey _key;
  final bool _isEnabled;
  final IWeb3App _web3app;
  Web3ModalTheme? _currentTheme;
  Timer? _timeOutTimer;
  String? _connectionChainId;
  bool _pageFinished = false;

  late final WebViewController _webViewController;
  late final WebViewWidget _webview;
  WebViewWidget get webview => _webview;

  bool _authenticated = false;
  bool get isAuthenticated => _authenticated;

  late Completer<bool> _initialized;
  Future<bool> awaitInit() => _initialized.future;

  late Completer<bool> _connected;
  Future<bool> awaitConnected() => _connected.future;

  late Completer<dynamic> _response;
  Future<dynamic> awaitResponse() => _response.future;

  @override
  Event<MagicSessionEvent> onMagicLoginRequest = Event<MagicSessionEvent>();

  @override
  Event<MagicConnectEvent> onMagicLoginSuccess = Event<MagicConnectEvent>();

  @override
  Event<MagicErrorEvent> onMagicError = Event<MagicErrorEvent>();

  @override
  Event<MagicSessionEvent> onMagicUpdate = Event<MagicSessionEvent>();

  @override
  Event<MagicRequestEvent> onMagicRpcRequest = Event<MagicRequestEvent>();

  final email = ValueNotifier<String>('');
  final newEmail = ValueNotifier<String>('');
  final step = ValueNotifier<EmailLoginStep>(EmailLoginStep.idle);

  MagicService({required IWeb3App web3app, bool enabled = false})
      : _web3app = web3app,
        _isEnabled = enabled {
    _key = GlobalKey(debugLabel: 'magic_service');
    if (_isEnabled) {
      _webViewController = WebViewController();
      _webview = WebViewWidget(controller: _webViewController);
    }
  }

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<void> init() async {
    _initialized = Completer<bool>();

    if (!_isEnabled) {
      _initialized.complete(false);
      _connected = Completer<bool>();
      _connected.complete(false);
      return;
    }

    _webViewController
      ..setBackgroundColor(Colors.transparent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (_isAllowedDomain(request.url)) {
              return NavigationDecision.navigate;
            }
            launchUrlString(request.url, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
          onWebResourceError: _onWebResourceError,
          onPageFinished: (String url) async {
            if (!_pageFinished) {
              _pageFinished = true;
              await _runJavascript(_web3app.core.projectId);
              await Future.delayed(Duration(milliseconds: 500));
              if (!_initialized.isCompleted) {
                _initialized.complete(true);
              }
              // in case connection message or even the request itself hangs there's no other way to continue the flow than timing it out.
              _timeOutTimer ??= Timer.periodic(
                Duration(seconds: 1),
                _checkTimeOut,
              );
            }
          },
        ),
      )
      ..enableZoom(false)
      ..addJavaScriptChannel('w3mWebview', onMessageReceived: _onFrameMessage)
      ..setOnConsoleMessage(_onDebugConsoleReceived);

    await loadRequest();

    if (kDebugMode) {
      try {
        // enable inspector for iOS
        if (Platform.isIOS) {
          final webKitCtlr =
              _webViewController.platform as WebKitWebViewController;
          webKitCtlr.setInspectable(true);
        }
      } catch (_) {}
      try {
        // enable inspector for Android
        if (Platform.isAndroid) {
          if (_webViewController.platform is AndroidWebViewController) {
            AndroidWebViewController.enableDebugging(true);
            (_webViewController.platform as AndroidWebViewController)
                .setMediaPlaybackRequiresUserGesture(false);

            final cookieManager =
                WebViewCookieManager().platform as AndroidWebViewCookieManager;
            cookieManager.setAcceptThirdPartyCookies(
                _webViewController.platform as AndroidWebViewController, true);
          }
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> loadRequest() async {
    try {
      final packageName = await WalletConnectUtils.getPackageName();
      final headers = {
        // secure-site's middleware requires a referer otherwise it throws `400: Missing projectId or referer`
        'referer': _web3app.metadata.url,
        'X-Bundle-Id': packageName,
      };
      final uri = _requestUri(packageName);
      await _webViewController.loadRequest(uri, headers: headers);
    } catch (e) {
      debugPrint('reload $e');
      _initialized.complete(false);
    }
  }

  @override
  void setEmail(String value) {
    email.value = value;
  }

  @override
  void setNewEmail(String value) {
    newEmail.value = value;
  }

  // ****** W3mFrameProvider public methods ******* //

  @override
  Future<void> connectEmail({required String value, String? chainId}) async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    _connectionChainId = chainId ?? _connectionChainId;
    final message = ConnectEmail(email: value).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> updateEmail({required String value}) async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    step.value = EmailLoginStep.loading;
    final message = UpdateEmail(email: value).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> updateEmailPrimaryOtp({required String otp}) async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    step.value = EmailLoginStep.loading;
    final message = UpdateEmailPrimaryOtp(otp: otp).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> updateEmailSecondaryOtp({required String otp}) async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    step.value = EmailLoginStep.loading;
    final message = UpdateEmailSecondaryOtp(otp: otp).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> connectOtp({required String otp}) async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    step.value = EmailLoginStep.loading;
    final message = ConnectOtp(otp: otp).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> isConnected() async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    _connected = Completer<bool>();
    final message = IsConnected().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> getChainId() async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    final message = GetChainId().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> syncTheme(Web3ModalTheme? theme) async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    _currentTheme = theme;
    final message = SyncTheme(theme: theme).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> syncDappData() async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    final message = SyncAppData(
      metadata: _web3app.metadata,
      projectId: _web3app.core.projectId,
      sdkVersion: 'flutter-${StringConstants.X_SDK_VERSION}',
    ).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> getUser({String? chainId}) async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    final message = GetUser(chainId: chainId).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> switchNetwork({required String chainId}) async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    final message = SwitchNetwork(chainId: chainId).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> request({required Map<String, dynamic> parameters}) async {
    if (!_isEnabled) return;
    _response = Completer<dynamic>();
    await _checkServiceReady();
    if (!_authenticated) {
      onMagicLoginRequest.broadcast(MagicSessionEvent(email: email.value));
      _connected = Completer<bool>();
      await connectEmail(value: email.value);
      final success = await _connected.future;
      if (!success) return;
    }
    onMagicRpcRequest.broadcast(MagicRequestEvent(request: parameters));
    final method = parameters['method'];
    final params = parameters['params'] as List;
    final message = RpcRequest(method: method, params: params).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
    // TODO THIS HAS TO BE REPLACED IN FAVOR OF PROER syncTheme() IMPLEMENTATION
    // _setModalColor();
  }

  @override
  Future<void> disconnect() async {
    if (!_isEnabled) return;
    await _checkServiceReady();
    final message = SignOut().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  // ****** Private Methods ******* //

  Future<void> _checkServiceReady() async {
    if (!_initialized.isCompleted || !(await _initialized.future)) {
      throw Exception('Service is not ready');
    }
    return;
  }

  void _onFrameMessage(JavaScriptMessage jsMessage) async {
    try {
      final frameMessage = jsMessage.toFrameMessage();
      if (!frameMessage.isValidOrigin || !frameMessage.isValidData) {
        return;
      }
      final messageData = frameMessage.data!;
      if (messageData.syncDataSuccess) {
        _resetTimeOut();
      }
      // ****** IS_CONNECTED
      if (messageData.isConnectSuccess) {
        _resetTimeOut();
        _authenticated = messageData.getPayloadMapKey<bool>('isConnected');
        if (!_connected.isCompleted) {
          _connected.complete(_authenticated);
        }
        if (_authenticated) {
          await getUser(chainId: _connectionChainId);
        }
      }
      // ****** CONNECT_EMAIL
      if (messageData.connectEmailSuccess) {
        if (step.value != EmailLoginStep.loading) {
          final action = messageData.getPayloadMapKey<String>('action');
          final value = action.toString().toUpperCase();
          final newStep = EmailLoginStep.fromAction(value);
          if (newStep == EmailLoginStep.verifyOtp) {
            if (step.value == EmailLoginStep.verifyDevice) {
              analyticsService.instance.sendEvent(DeviceRegisteredForEmail());
            }
            analyticsService.instance.sendEvent(EmailVerificationCodeSent());
          }
          step.value = newStep;
        }
      }
      // ****** CONNECT_OTP
      if (messageData.connectOtpSuccess) {
        analyticsService.instance.sendEvent(EmailVerificationCodePass());
        step.value = EmailLoginStep.idle;
        await getUser(chainId: _connectionChainId);
      }
      // ****** UPDAET_EMAIL
      if (messageData.updateEmailSuccess) {
        analyticsService.instance.sendEvent(EmailEdit());
        step.value = EmailLoginStep.verifyOtp;
      }
      // ****** UPDATE_EMAIL_PRIMARY_OTP
      if (messageData.updateEmailPrimarySuccess) {
        step.value = EmailLoginStep.verifyOtp2;
      }
      // ****** UPDATE_EMAIL_SECONDARY_OTP
      if (messageData.updateEmailSecondarySuccess) {
        analyticsService.instance.sendEvent(EmailEditComplete());
        step.value = EmailLoginStep.idle;
        setEmail(newEmail.value);
        setNewEmail('');
        await getUser(chainId: _connectionChainId);
      }
      // ****** SWITCH_NETWORK
      if (messageData.switchNetworkSuccess) {
        final chainId = messageData.getPayloadMapKey<int?>('chainId');
        onMagicUpdate.broadcast(MagicSessionEvent(chainId: chainId));
      }
      // ****** GET_CHAIN_ID
      if (messageData.getChainIdSuccess) {
        final chainId = messageData.getPayloadMapKey<int?>('chainId');
        onMagicUpdate.broadcast(MagicSessionEvent(chainId: chainId));
        _connectionChainId = chainId?.toString();
      }
      // ****** RPC_REQUEST
      if (messageData.rpcRequestSuccess) {
        final hash = messageData.payload as String?;
        _response.complete(hash);
        onMagicRpcRequest.broadcast(
          MagicRequestEvent(
            request: null,
            result: hash,
            success: true,
          ),
        );
      }
      // ****** GET_USER
      if (messageData.getUserSuccess) {
        _authenticated = true;
        final data = MagicData.fromJson(messageData.payload!);
        if (!_connected.isCompleted) {
          final event = MagicSessionEvent(
            email: data.email,
            address: data.address,
            chainId: data.chainId,
          );
          onMagicUpdate.broadcast(event);
          _connected.complete(_authenticated);
        } else {
          onMagicLoginSuccess.broadcast(MagicConnectEvent(data));
        }
      }
      // ****** SIGN_OUT
      if (messageData.signOutSuccess) {
        //
      }
      // ****** SESSION_UPDATE
      if (messageData.sessionUpdate) {
        // onMagicUpdate.broadcast(MagicSessionEvent(...));
      }
      if (messageData.isConnectError) {
        _error(IsConnectedErrorEvent());
      }
      if (messageData.connectEmailError) {
        _error(ConnectEmailErrorEvent());
      }
      if (messageData.updateEmailError) {
        _error(UpdateEmailErrorEvent());
      }
      if (messageData.connectOtpError) {
        analyticsService.instance.sendEvent(EmailVerificationCodeFail());
        _error(ConnectOtpErrorEvent());
      }
      if (messageData.getUserError) {
        _error(GetUserErrorEvent());
      }
      if (messageData.switchNetworkError) {
        _error(SwitchNetworkErrorEvent());
      }
      if (messageData.rpcRequestError) {
        final message = messageData.getPayloadMapKey<String?>('message');
        _error(RpcRequestErrorEvent(message));
      }
      if (messageData.signOutError) {
        _error(SignOutErrorEvent());
      }
    } catch (e, s) {
      loggerService.instance.e('[$runtimeType] $jsMessage', stackTrace: s);
    }
  }

  void _error(MagicErrorEvent errorEvent) {
    if (errorEvent is RpcRequestErrorEvent) {
      _response.complete(JsonRpcError(code: 0, message: errorEvent.error));
      onMagicRpcRequest.broadcast(
        MagicRequestEvent(
          request: null,
          result: JsonRpcError(code: 0, message: errorEvent.error),
          success: false,
        ),
      );
      return;
    }
    if (errorEvent is IsConnectedErrorEvent) {
      _authenticated = false;
      step.value = EmailLoginStep.idle;
    }
    if (errorEvent is ConnectEmailErrorEvent) {
      _authenticated = false;
      step.value = EmailLoginStep.idle;
    }
    if (errorEvent is UpdateEmailErrorEvent) {
      _authenticated = false;
      step.value = EmailLoginStep.verifyOtp;
    }
    if (errorEvent is ConnectOtpErrorEvent) {
      _authenticated = false;
      step.value = EmailLoginStep.verifyOtp;
    }
    if (!_connected.isCompleted) {
      _connected.complete(_authenticated);
    }
    onMagicError.broadcast(errorEvent);
  }

  Future<void> _runJavascript(String projectId) async {
    await _webViewController.runJavaScript('''
      const iframeFL = document.getElementById('frame-mobile-sdk')
      
      window.addEventListener('message', ({ data, origin }) => {
        console.log('message received <=== ' + JSON.stringify({data,origin}))
        window.w3mWebview.postMessage(JSON.stringify({data,origin}))
      })

      const sendMessage = async (message) => {
        console.log('message posted =====> ' + JSON.stringify(message))
        iframeFL.contentWindow.postMessage(message, '*')
      }

      // TODO this would have to be removed after proper implementation of syncTheme()
      // const setBGColor = (color) => {
      //   console.log('setBGColor =====> ' + color)
      //   document.body.style.backgroundColor = color
      //   const buttons = document.getElementsByClassName("signWrapper")
      //   buttons[0].style.backgroundColor = color
      // }
    ''');
  }

  void _onDebugConsoleReceived(JavaScriptConsoleMessage message) {
    if (kDebugMode) {
      loggerService.instance.d('[$runtimeType] JS Console ${message.message}');
    }
  }

  void _onWebResourceError(WebResourceError error) {
    debugPrint('''
              [$runtimeType] Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
              url: ${error.url}
            ''');
  }

  // ignore: unused_element
  void _setModalColor() {
    Future.delayed(Duration(milliseconds: 50), () {
      final isDarkMode = _currentTheme?.isDarkMode ?? false;
      final themeData = _currentTheme?.themeData ?? Web3ModalThemeData();
      final rbgColor = isDarkMode
          ? themeData.darkColors.background125
          : themeData.lightColors.background125;
      final jsColor = Util.colorToRGBA(rbgColor);
      _webViewController.runJavaScript('setBGColor("$jsColor")');
    });
  }

  bool _isAllowedDomain(String domain) {
    final domains = _safeDomains.join('|');
    return RegExp(r'' + domains).hasMatch(domain);
  }

  void _checkTimeOut(Timer time) {
    if (time.tick > 15) {
      _resetTimeOut();
      _error(IsConnectedErrorEvent());
    }
  }

  Uri _requestUri(String bundleId) {
    final uri = Uri.parse('https://$_url/mobile-sdk');
    final queryParams = {
      'projectId': _web3app.core.projectId,
      'bundleId': bundleId,
    };
    return uri.replace(queryParameters: queryParams);
  }

  void _resetTimeOut() {
    _timeOutTimer?.cancel();
    _timeOutTimer = null;
  }
}

extension JavaScriptMessageExtension on JavaScriptMessage {
  FrameMessage toFrameMessage() {
    final decodeMessage = jsonDecode(message) as Map<String, dynamic>;
    return FrameMessage.fromJson(decodeMessage);
  }
}
