import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web3modal_flutter/constants/string_constants.dart';
import 'package:web3modal_flutter/services/magic_service/i_magic_service.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_data.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_events.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_message.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: depend_on_referenced_packages
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_android/webview_flutter_android.dart';

class MagicServiceSingleton {
  late MagicService instance;
}

final magicService = MagicServiceSingleton();

class MagicService implements IMagicService {
  static const _url = 'https://secure.walletconnect.com';
  static const supportedMethods = [
    'personal_sign',
    'eth_sendTransaction',
    'eth_signTypedData_v4',
    'eth_signTransaction',
    'wallet_switchEthereumChain',
    'wallet_addEthereumChain',
  ];
  //
  late final String _projectId;
  late final PairingMetadata _metadata;

  // late final PlatformWebViewControllerCreationParams params;
  late WebViewController _webViewController;
  late WebViewWidget _webview;
  WebViewWidget get webview => _webview;

  late Completer<bool> _initialized;
  Future<bool> initialized() => _initialized.future;

  late Completer<bool> _connected;
  Future<bool> connected() => _connected.future;

  // late Completer<MagicData?> _userLogged;
  // Future<MagicData?> userLogged() => _userLogged.future;

  late Completer<dynamic> _response;
  Future<dynamic> response() => _response.future;

  @override
  Event<MagicConnectEvent> onMagicLogin = Event<MagicConnectEvent>();

  @override
  Event<MagicErrorEvent> onMagicError = Event<MagicErrorEvent>();

  @override
  Event<MagicSessionEvent> onMagicUpdate = Event<MagicSessionEvent>();

  @override
  Event<MagicRequestEvent> onMagicRequest = Event<MagicRequestEvent>();

  // void Function({dynamic request})? onRpcRequest;
  // void Function({String? response, String? error})? onRequestResponse;

  final email = ValueNotifier<String>('');
  final step = ValueNotifier<EmailLoginStep>(EmailLoginStep.idle);

  MagicService({
    required String projectId,
    required PairingMetadata metadata,
  })  : _projectId = projectId,
        _metadata = metadata;

  @override
  void init() {
    _initialized = Completer<bool>();

    // final headers = {
    //   // ...coreUtils.instance.getAPIHeaders(
    //   //   _projectId,
    //   //   _metadata.name,
    //   // ),
    //   'origin': _metadata.url,
    //   'sec-fetch-dest': 'iframe',
    //   'sec-fetch-mode': 'navigate',
    //   'sec-fetch-site': 'cross-site',
    // };

    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   params = WebKitWebViewControllerCreationParams(
    //     allowsInlineMediaPlayback: true,
    //     mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    //   );
    // } else {
    //   params = const PlatformWebViewControllerCreationParams();
    // }

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onWebResourceError: _onWebResourceError,
          onPageFinished: (String url) async {
            await _runJavascript(_projectId);
            await Future.delayed(Duration(milliseconds: 100));
            await _syncDappData();
            await _isConnected();
            if (!_initialized.isCompleted) {
              _initialized.complete(true);
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'w3mWebview',
        onMessageReceived: _onFrameMessage,
      )
      ..setOnConsoleMessage(_onDebugConsoleReceived)
      ..loadRequest(
        Uri.parse('$_url/sdk?projectId=$_projectId'),
        // headers: headers,
      );

    _webview = WebViewWidget(controller: _webViewController);

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
  void reload() {
    _webViewController.reload();
  }

  @override
  void setEmail(String value) => email.value = value;

  // ****** W3mFrameProvider public methods ******* //

  @override
  Future<void> connectEmail({required String email}) async {
    final message = ConnectEmail(email: email).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> connectDevice() async {
    final message = ConnectDevice().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> connectOtp({required String otp}) async {
    step.value = EmailLoginStep.loading;
    final message = ConnectOtp(otp: otp).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  // @override
  Future<void> _isConnected() async {
    _connected = Completer<bool>();
    final message = IsConnected().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> getChainId() async {
    final message = GetChainId().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  // Future<void> updateEmail({required String email}) async {
  //   await _webViewController.runJavaScript('provider.updateEmail(\'$email\')');
  // }

  @override
  Future<void> syncTheme(Web3ModalTheme? theme) async {
    final mode = theme?.isDarkMode == true ? 'dark' : 'light';
    final message = SyncTheme(mode: mode).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  // @override
  Future<void> _syncDappData() async {
    final message = SyncAppData(
      metadata: _metadata,
      sdkVersion: 'flutter-${StringConstants.X_SDK_VERSION}',
      projectId: _projectId,
    ).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> getUser({String? chainId}) async {
    // _userLogged = Completer<MagicData?>();
    final message = GetUser(chainId: chainId).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> switchNetwork({required String chainId}) async {
    final message = SwitchNetwork(chainId: chainId).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> request({required Map<String, dynamic> parameters}) async {
    _response = Completer<dynamic>();
    onMagicRequest.broadcast(MagicRequestEvent(request: parameters));
    final method = parameters['method'];
    final params = parameters['params'] as List;
    final message = RpcRequest(method: method, params: params).toString();
    await _webViewController.runJavaScript('sendMessage($message)');
  }

  @override
  Future<void> disconnect() async {
    final message = SignOut().toString();
    await _webViewController.runJavaScript('sendMessage($message)');
    // _signOutTimer ??= Timer.periodic(Duration(seconds: 2), _diconnectCallback);
  }

  // ****** Private Methods ******* //

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
        _connected.complete(isConnected);
      }
      if (messageMap.isConnectError) {
        _connected.complete(false);
        onMagicError.broadcast(MagicErrorEvent('Error checking isConnected'));
      }
      if (messageMap.connectEmailSuccess) {
        if (step.value != EmailLoginStep.loading) {
          final action = messageMap.payload?['action'] ?? '';
          final value = action.toString().toUpperCase();
          step.value = EmailLoginStep.fromAction(value);
        }
      }
      if (messageMap.connectEmailError) {
        onMagicError.broadcast(MagicErrorEvent('Error connecting email'));
      }
      if (messageMap.connectOtpSuccess) {
        await getUser();
      }
      if (messageMap.connectOtpError) {
        onMagicError.broadcast(MagicErrorEvent('Error connecting OTP'));
      }
      if (messageMap.sessionUpdate) {
        // onMagicUpdate.broadcast(MagicSessionEvent(...));
      }
      if (messageMap.getUserSuccess) {
        final data = MagicData.fromJson(messageMap.payload!);
        // _userLogged.complete(data);
        onMagicLogin.broadcast(MagicConnectEvent(data));
      }
      if (messageMap.getUserError) {
        // _userLogged.complete(null);
        onMagicError.broadcast(MagicErrorEvent('Error getting user'));
      }
      if (messageMap.switchNetworkSuccess) {
        final chainId = messageMap.payload?['chainId'] as int?;
        onMagicUpdate.broadcast(MagicSessionEvent(chainId: chainId));
      }
      if (messageMap.switchNetworkError) {
        onMagicError.broadcast(MagicErrorEvent('Error switching network'));
      }
      if (messageMap.rpcRequestSuccess) {
        final hash = messageMap.payload as String?;
        _response.complete(hash);
        onMagicRequest.broadcast(MagicRequestEvent(
          request: null,
          result: hash,
          success: true,
        ));
      }
      if (messageMap.rpcRequestError) {
        final message = messageMap.payload?['message'] as String?;
        _response.complete(JsonRpcError(code: 0, message: message));
        onMagicRequest.broadcast(MagicRequestEvent(
          request: null,
          result: JsonRpcError(code: 0, message: message),
          success: false,
        ));
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
