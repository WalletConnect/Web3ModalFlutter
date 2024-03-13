import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/logger_service/logger_service_singleton.dart';
import 'package:web3modal_flutter/services/magic_service/i_magic_service.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_data.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_events.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_message.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class MagicServiceSingleton {
  late MagicService instance;
}

final magicService = MagicServiceSingleton();

class MagicService implements IMagicService {
  static const _origin = 'secure.walletconnect.com';
  static const _url = 'secure-mobile.walletconnect.com/mobile-sdk';
  static const _safeDomains = [
    'walletconnect.com',
    'magic.link',
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
  late final IWeb3App _web3app;
  Web3ModalTheme? _currentTheme;
  Timer? _timeOutTimer;

  final _webViewController = WebViewController();
  late WebViewWidget _webview;
  WebViewWidget get webview => _webview;

  late Completer<bool> _initialized;
  Future<bool> initialized() => _initialized.future;

  bool _authenticated = false;
  late Completer<bool> _connected;
  Future<bool> connected() => _connected.future;

  late Completer<dynamic> _response;
  Future<dynamic> response() => _response.future;

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
  final step = ValueNotifier<EmailLoginStep>(EmailLoginStep.idle);

  MagicService({required IWeb3App web3app}) : _web3app = web3app {
    _webview = WebViewWidget(
      controller: _webViewController,
    );
  }

  @override
  Future<void> init() async {
    _initialized = Completer<bool>();

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
            await _runJavascript(_web3app.core.projectId);
            await Future.delayed(Duration(milliseconds: 100));
            if (!_initialized.isCompleted) {
              _initialized.complete(true);
            }
          },
        ),
      )
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
        // TODO check if sending _web3app.metadata.url is OK
        'referer': _web3app.metadata.url,
        'X-Bundle-Id': packageName,
      };
      await _webViewController.loadRequest(_requestUri, headers: headers);
      // in case connection message or even the request itself hangs there's no other way to continue the flow than timing it out.
      _timeOutTimer ??= Timer.periodic(Duration(seconds: 1), _checkTimeOut);
    } catch (e) {
      debugPrint('reload $e');
      _initialized.complete(false);
    }
  }

  @override
  void setEmail(String value) => email.value = value;

  // ****** W3mFrameProvider public methods ******* //

  @override
  Future<void> connectEmail({required String value}) async {
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
    final message = ConnectEmail(email: value).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> connectDevice() async {
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
    final message = ConnectDevice().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> connectOtp({required String otp}) async {
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
    step.value = EmailLoginStep.loading;
    final message = ConnectOtp(otp: otp).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> isConnected() async {
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
    _connected = Completer<bool>();
    final message = IsConnected().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> getChainId() async {
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
    final message = GetChainId().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  // Future<void> updateEmail({required String email}) async {
  //   await _webViewController.runJavaScript('provider.updateEmail(\'$email\')');
  // }

  @override
  Future<void> syncTheme(Web3ModalTheme? theme) async {
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
    _currentTheme = theme;
    final message = SyncTheme(theme: theme).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> syncDappData() async {
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
    final message = SyncAppData(
      metadata: _web3app.metadata,
      projectId: _web3app.core.projectId,
      sdkVersion: 'flutter-${StringConstants.X_SDK_VERSION}',
    ).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> getUser({String? chainId}) async {
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
    final message = GetUser(chainId: chainId).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> switchNetwork({required String chainId}) async {
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
    final message = SwitchNetwork(chainId: chainId).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> request({required Map<String, dynamic> parameters}) async {
    _response = Completer<dynamic>();
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
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
    if (!_initialized.isCompleted || !(await _initialized.future)) return;
    final message = SignOut().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  // ****** Private Methods ******* //

  void _onDebugConsoleReceived(JavaScriptConsoleMessage message) {
    if (kDebugMode) {
      // loggerService.instance.d('[$runtimeType] JS Console ${message.message}');
    }
  }

  void _onFrameMessage(JavaScriptMessage message) async {
    try {
      final decodeMessage = jsonDecode(message.message) as Map<String, dynamic>;
      final messageOrigin = decodeMessage['origin'] as String;
      final messageData = decodeMessage['data'] as Map<String, dynamic>;
      final messageMap = MagicMessage.fromJson(messageData);
      if (!_isAllowedOrigin(messageOrigin)) {
        return;
      }
      if (messageMap.syncDataSuccess) {
        _resetTimeOut();
      }
      // ****** IS_CONNECTED
      if (messageMap.isConnectSuccess) {
        _authenticated = messageMap.payload?['isConnected'] as bool;
        if (!_connected.isCompleted) {
          _connected.complete(_authenticated);
        }
        if (_authenticated) {
          await getUser();
        }
      }
      if (messageMap.isConnectError) {
        _error('Error checking isConnected');
      }
      // ****** CONNECT_EMAIL
      if (messageMap.connectEmailSuccess) {
        if (step.value != EmailLoginStep.loading) {
          final action = messageMap.payload?['action'] ?? '';
          final value = action.toString().toUpperCase();
          step.value = EmailLoginStep.fromAction(value);
        }
      }
      if (messageMap.connectEmailError) {
        _error('Error connecting email');
      }
      // ****** CONNECT_OTP
      if (messageMap.connectOtpSuccess) {
        await getUser();
      }
      if (messageMap.connectOtpError) {
        _error('Error connecting OTP');
      }
      // ****** GET_USER
      if (messageMap.getUserSuccess) {
        _authenticated = true;
        final data = MagicData.fromJson(messageMap.payload!);
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
      if (messageMap.getUserError) {
        _error('Error getting user');
      }
      // ****** SWITCH_NETWORK
      if (messageMap.switchNetworkSuccess) {
        final chainId = messageMap.payload?['chainId'] as int?;
        onMagicUpdate.broadcast(MagicSessionEvent(chainId: chainId));
      }
      if (messageMap.switchNetworkError) {
        _error('Error switching network');
      }
      // ****** RPC_REQUEST
      if (messageMap.rpcRequestSuccess) {
        final hash = messageMap.payload as String?;
        _response.complete(hash);
        onMagicRpcRequest.broadcast(
          MagicRequestEvent(
            request: null,
            result: hash,
            success: true,
          ),
        );
      }
      if (messageMap.rpcRequestError) {
        final message = messageMap.payload?['message'] as String?;
        _response.complete(JsonRpcError(code: 0, message: message));
        onMagicRpcRequest.broadcast(
          MagicRequestEvent(
            request: null,
            result: JsonRpcError(code: 0, message: message),
            success: false,
          ),
        );
      }
      // ****** SIGN_OUT
      if (messageMap.signOutSuccess) {
        //
      }
      if (messageMap.signOutError) {
        //
      }
      if (messageMap.sessionUpdate) {
        // onMagicUpdate.broadcast(MagicSessionEvent(...));
      }
    } catch (e, s) {
      loggerService.instance.e(
        '[MagicService] error ${message.message}',
        error: e,
        stackTrace: s,
      );
    }
  }

  void _error(String errorMessage) {
    _authenticated = false;
    if (!_connected.isCompleted) {
      _connected.complete(_authenticated);
    }
    onMagicError.broadcast(MagicErrorEvent(errorMessage));
    loggerService.instance.e('[MagicService] error $errorMessage');
  }

  Future<void> _runJavascript(String projectId) async {
    await _webViewController.runJavaScript('''
      const iframeFL = document.getElementById('frame-mobile-sdk')
      
      window.addEventListener('message', ({ data, origin }) => {
        console.log('message received <===== ' + JSON.stringify({data,origin}))
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

  bool _isAllowedOrigin(String origin) {
    return Uri.parse(origin).authority == _origin;
  }

  void _checkTimeOut(Timer time) {
    debugPrint(time.tick.toString());
    if (time.tick > 15) {
      _resetTimeOut();
      _error('Error checking isConnected');
    }
  }

  Uri get _requestUri {
    final uri = Uri.parse('https://$_url');
    final queryParams = {'projectId': _web3app.core.projectId};
    return uri.replace(queryParameters: queryParams);
  }

  void _resetTimeOut() {
    _timeOutTimer?.cancel();
    _timeOutTimer = null;
  }
}
