// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_message.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_user_data.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

final magicService = MagicServiceSingleton();

class MagicServiceSingleton {
  MagicService instance;

  MagicServiceSingleton() : instance = MagicService();
}

class MagicService {
  static const _url = 'https://secure.walletconnect.com';
  // static const _url = 'https://da2a32fe218f.ngrok.app';
  //
  late final String _projectId;
  late final PairingMetadata _metadata;
  late final BuildContext _context;
  // Timer? _signOutTimer;

  bool _initialized = false;
  bool get initialized => _initialized;

  late WebViewWidget _webview;
  WebViewWidget get webview => _webview;

  late WebViewController _webViewController;

  void Function({bool error})? onInit;
  void Function({MagicUserData? userData})? onUserConnected;
  void Function({dynamic error})? onError;
  void Function({String? chainId})? onNetworkChange;
  void Function({dynamic request})? onRpcRequest;
  void Function({String? response, String? error})? onRequestResponse;

  final email = ValueNotifier<String>('');
  final mailAction = ValueNotifier<String>('');

  void init({
    required String projectId,
    required PairingMetadata metadata,
    required BuildContext context,
  }) {
    _projectId = projectId;
    _metadata = metadata;
    _context = context;

    final headers = {
      ...coreUtils.instance.getAPIHeaders(
        _projectId,
        'Web3ModalV3Example',
      ),
      'origin': 'com.web3modal.flutterExample'
    };

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            debugPrint(
                '[$runtimeType] navigation main: ${request.isMainFrame} ${request.url}');
            return NavigationDecision.navigate;
          },
          onWebResourceError: _onWebResourceError,
          onPageFinished: (String url) async {
            await _runJavascript(projectId);
            Future.delayed(Duration(milliseconds: 500), () {
              syncDappData();
              _syncTheme();
              isConnected();
            });
            Future.delayed(Duration(seconds: 10), () {
              if (!_initialized) {
                _onInit(error: true);
              }
            });
          },
        ),
      )
      ..addJavaScriptChannel('w3mWebview', onMessageReceived: _onFrameMessage)
      ..setOnConsoleMessage(_onDebugConsoleReceived)
      ..loadRequest(
        Uri.parse('$_url/sdk?projectId=$projectId'),
        headers: headers,
      );

    _webview = WebViewWidget(controller: _webViewController);

    try {
      // enable inspector for iOS
      final webKitCtlr = _webViewController.platform as WebKitWebViewController;
      webKitCtlr.setInspectable(true);
    } catch (_) {}
    try {
      // enable inspector for Android
      if (_webViewController.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        (_webViewController.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);

        final cookieManager =
            WebViewCookieManager().platform as AndroidWebViewCookieManager;
        cookieManager.setAcceptThirdPartyCookies(
            _webViewController.platform as AndroidWebViewController, true);
      }
    } catch (_) {}
  }

  void setEmail(String value) => email.value = value;

  // ****** W3mFrameProvider public methods ******* //

  Future<void> connectEmail({required String email}) async {
    final message = ConnectEmail(email: email).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  Future<void> connectDevice() async {
    final message = ConnectDevice().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  Future<void> connectOtp({required String otp}) async {
    mailAction.value = 'LOADING';
    final message = ConnectOtp(otp: otp).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  Future<void> isConnected() async {
    final message = IsConnected().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  Future<void> getChainId() async {
    final message = GetChainId().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  // Future<void> updateEmail({required String email}) async {
  //   await _webViewController.runJavaScript('provider.updateEmail(\'$email\')');
  // }

  Future<void> syncTheme() async {
    if (!_initialized) return;
    await _syncTheme();
  }

  Future<void> _syncTheme() async {
    final theme = Web3ModalTheme.maybeOf(_context);
    final mode = theme?.isDarkMode == true ? 'dark' : 'light';
    final message = SyncTheme(mode: mode).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  Future<void> syncDappData() async {
    final message = SyncAppData(
      metadata: _metadata,
      sdkVersion: 'flutter-${StringConstants.X_SDK_VERSION}',
      projectId: _projectId,
    ).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  Future<void> getUser({String? chainId}) async {
    final message = GetUser(chainId: chainId).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  Future<void> switchNetwork({required String chainId}) async {
    final message = SwitchNetwork(chainId: chainId).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  Future<void> disconnect() async {
    final message = SignOut().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
    // _signOutTimer ??= Timer.periodic(Duration(seconds: 2), _diconnectCallback);
  }

  // void _diconnectCallback(Timer timer) async {
  //   disconnect();
  // }

  Future<void> request({required Map<String, dynamic> parameters}) async {
    final method = parameters['method'];
    final params = parameters['params'] as List;
    final message = RpcRequest(method: method, params: params).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
    onRpcRequest?.call(request: parameters);
  }

  // ****** Private Methods ******* //

  void _onInit({required bool error}) {
    if (_initialized) return;
    _initialized = !error;
    onInit?.call(error: error);
  }

  void _onUserConnected({Map<String, dynamic>? payload}) {
    try {
      final userData = MagicUserData.fromJson(payload!);
      onUserConnected?.call(userData: userData);
    } catch (e) {
      onError?.call(error: e);
    }
  }

  void _onDebugConsoleReceived(JavaScriptConsoleMessage message) {
    debugPrint('[$runtimeType] Console ${message.message}');
  }

  void _onFrameMessage(JavaScriptMessage message) async {
    if (message.message == 'verify_ready') {
      return;
    }
    try {
      final jsonMessage = jsonDecode(message.message) as Map<String, dynamic>;
      if (jsonMessage.containsKey('msgType')) {
        return;
      }
      final messageMap = MagicMessage.fromJson(jsonMessage);
      debugPrint('[$runtimeType] _onFrameMessage ${message.message}');

      if (messageMap.isConnectSuccess) {
        final isConnected = messageMap.payload?['isConnected'] as bool;
        if (isConnected) {
          await getUser();
        }
        _onInit(error: false);
      }

      if (messageMap.isConnectError) {
        _onInit(error: true);
      }
      if (messageMap.connectEmailSuccess) {
        // {action: "VERIFY_DEVICE"} it means the device verication email has been sent
        // {action: "VERIFY_OTP"} it means the otp code has been sent
        if (mailAction.value != 'LOADING') {
          final action = messageMap.payload?['action'] ?? '';
          mailAction.value = action.toString().toLowerCase();
        }
      }
      if (messageMap.connectEmailError) {
        //
      }
      if (messageMap.connectOtpSuccess) {
        await getUser();
      }
      if (messageMap.connectOtpError) {
        //
      }
      if (messageMap.sessionUpdate) {
        // {token: "asa8df67g5f6d7asf7d5gs6"}
      }
      if (messageMap.getUserSuccess) {
        // {email: "alfredo@walletconnect.com", address: "0x6c6DF521E82F6FA82dE2378cfA9eB97822f33c23", chainId: 1}
        _onUserConnected(payload: messageMap.payload);
      }
      if (messageMap.getUserError) {
        //
      }
      if (messageMap.switchNetworkSuccess) {
        final chainId = messageMap.payload?['chainId'] as int?;
        onNetworkChange?.call(chainId: chainId?.toString());
      }
      if (messageMap.switchNetworkError) {
        //
      }
      if (messageMap.rpcRequestSuccess) {
        final hash = messageMap.payload as String?;
        onRequestResponse?.call(response: hash, error: null);
      }
      if (messageMap.rpcRequestError) {
        final message = messageMap.payload?['message'] as String?;
        onRequestResponse?.call(error: message);
      }
      // if (messageMap.signOutSuccess) {
      //   //
      //   _signOutTimer?.cancel();
      //   _signOutTimer = null;
      // }
    } catch (e) {
      debugPrint('[$runtimeType] message error $e');
      debugPrint('[$runtimeType] ${message.message}');
    }
  }

  Future<void> _runJavascript(String projectId) async {
    await _webViewController.runJavaScript('''
      window.addEventListener('message', ({ data }) => {
        window.w3mWebview.postMessage(JSON.stringify(data))
      })

      const sendMessage = async (message) => {
        postMessage(message, '*')
      }
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
}
