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
  static const _url = 'https://secure.web3modal.com';
  // static const _url = 'https://0a12-81-202-242-236.ngrok-free.app';
  //
  static const _packageUrl = 'https://esm.sh/@web3modal/wallet@3.6.0-2c10ca76';
  //
  bool _initialized = false;
  MagicUserData? _currentUser;

  late WebViewController _webViewController;
  WebViewController get controller => _webViewController;

  void Function({bool error})? onInit;
  void Function({MagicUserData? userData})? onUserConnected;
  void Function({dynamic error})? onError;
  void Function({String? chainId})? onNetworkChange;

  final email = ValueNotifier<String>('');
  final processing = ValueNotifier<bool>(false);

  void init({required String projectId}) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onWebResourceError: _onWebResourceError,
          onPageFinished: (String url) async {
            await _runJavascript(projectId);
          },
        ),
      )
      ..addJavaScriptChannel('w3mWebview', onMessageReceived: _onFrameMessage)
      ..setOnConsoleMessage(_onDebugConsoleReceived)
      ..loadRequest(Uri.parse('$_url/dashboard'));

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

  Future<void> getLoginEmailUsed() async {
    await _webViewController.runJavaScript('getLoginEmailUsed()');
  }

  Future<void> getEmail() async {
    await _webViewController.runJavaScript('getEmail()');
  }

  Future<void> connectEmail({required String email}) async {
    await _webViewController.runJavaScript('connectEmail(\'$email\')');
  }

  Future<void> connectDevice() async {
    await _webViewController.runJavaScript('connectDevice()');
  }

  Future<void> connectOtp({required String otp}) async {
    processing.value = true;
    await _webViewController.runJavaScript('connectOtp(\'$otp\')');
  }

  Future<void> isConnected() async {
    await _webViewController.runJavaScript('isConnected()');
  }

  Future<void> getChainId() async {
    await _webViewController.runJavaScript('getChainId()');
  }

  Future<void> updateEmail({required String email}) async {
    await _webViewController.runJavaScript('updateEmail(\'$email\')');
  }

  Future<void> awaitUpdateEmail({required String email}) async {
    await _webViewController.runJavaScript('awaitUpdateEmail()');
  }

  Future<void> syncTheme({required dynamic theme}) async {
    await _webViewController.runJavaScript('syncTheme(\'$theme\')');
  }

  Future<void> syncDappData({required dynamic appData}) async {
    await _webViewController.runJavaScript('syncDappData(\'$appData\')');
  }

  Future<void> connect({Map<String, dynamic>? params}) async {
    await _webViewController.runJavaScript('connect(\'$params\')');
  }

  Future<void> switchNetwork({required String chainId}) async {
    await _webViewController.runJavaScript('switchNetwork($chainId)');
  }

  Future<void> disconnect() async {
    await _webViewController.runJavaScript('disconnect()');
  }

  Future<void> request({required Map<String, dynamic> parameters}) async {
    // final parameters = jsonEncode(params);
    // print(parameters);
    // provider.request({method:"personal_sign",params:["Test Web3Modal data","0x6c6DF521E82F6FA82dE2378cfA9eB97822f33c23"]})
    final method = parameters['method'];
    final params = parameters['params'] as List;
    final p = '{method:"$method",params:["${params.first}","${params.last}"]}';
    await _webViewController.runJavaScript('request($p)');
  }

  // ****** Private Methods ******* //

  void _onInit({required bool error}) {
    if (_initialized) return;
    _initialized = true;
    onInit?.call(error: error);
  }

  void _onUserConnected({Map<String, dynamic>? payload}) {
    try {
      _currentUser = MagicUserData.fromJson(payload ?? {});
      onUserConnected?.call(userData: _currentUser);
    } catch (e) {
      onError?.call(error: e);
    }
  }

  void _onDebugConsoleReceived(JavaScriptConsoleMessage message) {
    debugPrint('[$runtimeType] Console ${message.message}');
  }

  void _onFrameMessage(JavaScriptMessage message) async {
    try {
      final messageMap = MagicMessage.fromJson(jsonDecode(message.message));
      debugPrint('[$runtimeType] _onFrameMessage ${message.message}');
      if (messageMap.frameLoaded) {
        await isConnected();
      }
      if (messageMap.connectSuccess) {
        // with messageMap.payload {isConnected: "true/false"}
        _onInit(error: false);
      }
      if (messageMap.connectError) {
        _onInit(error: true);
      }
      if (messageMap.emailSuccess) {
        // with messageMap.payload {action: "VERIFY_OTP"} it means the otp code has been sent
      }
      if (messageMap.connectOtp) {
        // with messageMap.payload {otp: "123456"} when the otp code is entered
      }
      if (messageMap.otpSuccess) {
        await connect();
      }
      if (messageMap.sessionUpdate) {
        // with messageMap.payload {token: "asa8df67g5f6d7asf7d5gs6"}
      }
      if (messageMap.userSuccess) {
        // with messageMap.payload {email: "alfredo@walletconnect.com", address: "0x6c6DF521E82F6FA82dE2378cfA9eB97822f33c23", chainId: 1}
        _onUserConnected(payload: messageMap.payload);
      }
      if (messageMap.switchNetwork) {
        // with messageMap.payload {chainId: 123}
      }
      if (messageMap.networkSuccess) {
        // with messageMap.payload {chainId: 123}
        final chainId = messageMap.payload?['chainId'];
        onNetworkChange?.call(chainId: chainId.toString());
      }
    } catch (e) {
      debugPrint('[$runtimeType] _onFrameMessage error $e');
    }
  }

  Future<void> _runJavascript(String projectId) async {
    await _webViewController.runJavaScript('''
      let provider;
      import('$_packageUrl').then((package) => {
        provider = new package.W3mFrameProvider('$projectId')
        provider.onRpcRequest((request) => {
          console.log('onRpcRequest')
          // console.log(request)
          window.w3mWebview.postMessage(JSON.stringify(request))
        })
        provider.onRpcResponse((response) => {
          console.log('onRpcResponse')
          // console.log(response)
          window.w3mWebview.postMessage(JSON.stringify(response))
        })
      });

      const getLoginEmailUsed = async () => {
        await provider.getLoginEmailUsed();
      }

      const getEmail = async () => {
        await provider.getEmail();
      }

      const connectEmail = async (email) => {
        await provider.connectEmail({ email })
      }

      const connectDevice = async () => {
        await provider.connectDevice()
      }

      const connectOtp = async (otp) => {
        await provider.connectOtp({ otp })
      }

      const isConnected = async () => {
        await provider.isConnected();
      }

      const getChainId = async () => {
        await provider.getChainId()
      }

      const updateEmail = async (email) => {
        await provider.updateEmail({ email })
      }

      const awaitUpdateEmail = async () => {
        await provider.awaitUpdateEmail()
      }

      const syncTheme = async (theme) => {
        await provider.syncTheme({ theme })
      }

      const syncDappData = async (appData) => {
        await provider.syncDappData({ appData })
      }

      const connect = async (params) => {
        await provider.connect({ params })
      }

      const switchNetwork = async (chainId) => {
        await provider.switchNetwork(chainId)
      }

      const disconnect = async () => {
        await provider.disconnect()
      }

      const request = async (params) => {
        console.log(params)
        await provider.request(params)
      }

      const iframeO = document.createElement('iframe')
      iframeO.id = 'w3m-iframe'
      iframeO.src = '$_url/sdk?projectId=$projectId'
      iframeO.style.position = 'fixed'
      iframeO.style.zIndex = '999999'
      iframeO.style.display = 'none'
      iframeO.style.opacity = '0'
      iframeO.style.borderRadius = `clamp(0px, var(--wui-border-radius-l), 44px)`

      document.body.appendChild(iframeO)

      iframeO.onload = () => {
        window.w3mWebview.postMessage(JSON.stringify(${FrameLoaded().toString()}))

        window.addEventListener('message', ({ data }) => {
          window.w3mWebview.postMessage(JSON.stringify(data))
        })
      }

      iframeO.onerror = () => {
        window.w3mWebview.postMessage(JSON.stringify(${FrameError().toString()}))
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
