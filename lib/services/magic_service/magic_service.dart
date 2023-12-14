// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_message.dart';
import 'package:web3modal_flutter/services/magic_service/models/magic_user_data.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

final magicService = MagicServiceSingleton();

class MagicServiceSingleton {
  MagicService instance;

  MagicServiceSingleton() : instance = MagicService();
}

class MagicService {
  static const _url =
      'https://secure-web3modal-git-preview-3-walletconnect1.vercel.app/sdk';
  // static const _url2 = 'http://192.168.0.83:3010/sdk';
  //
  static const _packageUrl =
      'https://esm.sh/@web3modal/smart-account@3.4.0-e3959a31';
  // static const _packageUrl2 =
  //     'https://esm.sh/@web3modal/smart-account@3.4.0-7c9b36dd';
  //
  static const _initialized = '{type: \'@w3m-app/INITIALIZED\'}';
  static const _frameLoaded = '{type: \'@w3m-app/FRAME_LOADED\'}';
  static const _frameError = '{type: \'@w3m-frame/ERROR\'}';
  //
  // static const _htmlString = '<html><body></body></html>';

  // static const _authorizedHosts = [
  //   'web3modal.com',
  //   'secure-web3modal-git-preview-3-walletconnect1.vercel.app',
  //   'verify.walletconnect.com',
  //   'auth.magic.link',
  // ];

  MagicUserData? _currentUser;

  late WebViewController _webViewController;
  WebViewController get controller => _webViewController;

  void Function({bool error})? onInit;
  void Function({MagicUserData? userData})? onUserConnected;
  void Function({dynamic error})? onError;

  final email = ValueNotifier<String>('');
  final processing = ValueNotifier<bool>(false);

  void init({required String projectId}) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // final uri = Uri.parse(request.url);
            // debugPrint(uri.host);
            // debugPrint('-----');
            // if (!_authorizedHosts.contains(uri.host)) {
            //   debugPrint('[$runtimeType] blocking ${request.url}');
            //   return NavigationDecision.prevent;
            // }
            // debugPrint('[$runtimeType] Allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              [$runtimeType] Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
              url: ${error.url}
            ''');
          },
          onPageFinished: (String url) async {
            await _runJavascript(projectId);
          },
        ),
      )
      ..addJavaScriptChannel(
        'w3mWebview',
        onMessageReceived: _onMessageReceived,
      )
      ..setOnConsoleMessage(_onDebugConsoleReceived)
      ..loadRequest(Uri.parse('https://web3modal.com'));

    try {
      // enable inspector for iOS
      final webKitController =
          _webViewController.platform as WebKitWebViewController;
      webKitController.setInspectable(true);
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

  void _onInit({required bool error}) => onInit?.call(error: error);

  void setEmail(String value) => email.value = value;

  Future<void> checkConnected() async {
    await _webViewController.runJavaScript('checkConnected()');
  }

  Future<void> connectEmail() async {
    await _webViewController.runJavaScript('connectEmail(\'${email.value}\')');
  }

  Future<void> connectDevice() async {
    await _webViewController.runJavaScript('connectDevice()');
  }

  Future<void> connectOtp({required String otp}) async {
    processing.value = true;
    await _webViewController.runJavaScript('connectOtp(\'$otp\')');
  }

  Future<void> connectUser() async {
    await _webViewController.runJavaScript('connect()');
  }

  void _onUserConnected({Map<String, dynamic>? payload}) {
    try {
      _currentUser = MagicUserData.fromJson(payload ?? {});
      onUserConnected?.call(userData: _currentUser);
    } catch (e) {
      onError?.call(error: e);
    }
  }

  Future<void> getChainId() async {
    await _webViewController.runJavaScript('getChainId()');
  }

  Future<void> switchNetowrk({required String chainId}) async {
    debugPrint('switchNetowrk($chainId)');
    final cid = int.parse(chainId);
    await _webViewController.runJavaScript('switchNetowrk($cid)');
  }

  Future<void> request({required Map<String, dynamic> body}) async {
    await _webViewController.runJavaScript('request(\'${jsonEncode(body)}\')');
  }

  // Future<void> personalSign({required String message}) async {
  //   Map<String, dynamic> body = {
  //     'params': [message, _currentUser!.address],
  //     'method': 'personal_sign',
  //   };
  //   return request(body: body);
  // }

  Future<void> disconnectUser() async {
    await _webViewController.runJavaScript('disconnect()');
  }

  Future<void> _runJavascript(String projectId) async {
    await _webViewController.runJavaScript('''
      let provider;
      import('$_packageUrl').then((package) => {
        provider = new package.W3mFrameProvider('$projectId')
        // checkConnected()
      });

      const checkConnected = async () => {
        // await provider.isConnected();
        window.w3mWebview.postMessage(JSON.stringify($_initialized))
      }

      const connectEmail = async (email) => {
        console.log('connectEmail(' + email + ')')
        await provider.connectEmail({ email })
      }

      const connectDevice = async () => {
        console.log('connectDevice()')
        await provider.connectDevice()
      }

      const connectOtp = async (otp) => {
        console.log('connectOtp(' + otp + ')')
        await provider.connectOtp({ otp })
      }

      const connect = async () => {
        console.log('connect()')
        await provider.connect()
      }

      const getChainId = async () => {
        console.log('getChainId()')
        await provider.getChainId()
      }

      const switchNetowrk = async (chainId) => {
        console.log('switchNetowrk(' + chainId + ')')
        await provider.switchNetowrk({ chainId })
      }

      const request = async (req) => {
        console.log('request(' + req + ')')
        await provider.request({ req })
      }

      const disconnect = async () => {
        console.log('disconnect()')
        await provider.disconnect()
      }

      const iframeO = document.createElement('iframe')
      iframeO.id = 'w3m-iframe'
      iframeO.src = '$_url'
      document.body.appendChild(iframeO)

      iframeO.onload = () => {
        window.w3mWebview.postMessage(JSON.stringify($_frameLoaded))

        window.addEventListener('message', ({ data }) => {
          window.w3mWebview.postMessage(JSON.stringify(data))
        })
      }

      iframeO.onerror = () => {
        window.w3mWebview.postMessage(JSON.stringify($_frameError))
      }
    ''');
  }

  void _onDebugConsoleReceived(JavaScriptConsoleMessage message) {
    debugPrint('[$runtimeType] Console ${message.message}');
  }

  void _onMessageReceived(JavaScriptMessage message) async {
    try {
      final messageMap = MagicMessage.fromJson(jsonDecode(message.message));
      debugPrint('[$runtimeType] Received ${messageMap.toJson()}');
      if (messageMap.loaded) {
        checkConnected();
      }
      if (messageMap.initialized) {
        // TODO this would have to be removed then IS_CONNECTED starts working
        final fakeMessage = '{"type":"@w3m-frame/IS_CONNECTED_SUCCESS"}';
        _onMessageReceived(JavaScriptMessage(message: fakeMessage));
      }
      if (messageMap.connected) {
        _onInit(error: false);
      }
      if (messageMap.error) {
        _onInit(error: true);
      }
      if (messageMap.otp) {
        connectUser();
      }
      if (messageMap.userData) {
        _onUserConnected(payload: messageMap.payload);
      }
    } catch (e) {
      debugPrint('[$runtimeType] error ${message.message} $e');
    }
  }
}
