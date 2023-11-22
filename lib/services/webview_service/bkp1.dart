import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebviewServiceSingleton {
  WebviewService instance;

  WebviewServiceSingleton() : instance = WebviewService();
}

final webviewService = WebviewServiceSingleton();

const _url =
    'https://secure-web3modal-git-preview-3-walletconnect1.vercel.app/sdk';

class WebviewService {
  late WebViewController controller;
  bool isLoaded = false;

  void Function({bool error})? onInit;

  void init({required String projectId}) {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   debugPrint('[$runtimeType] blocking ${request.url}');
            //   return NavigationDecision.prevent;
            // }
            debugPrint('[$runtimeType] Allowing navigation to ${request.url}');
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
          onUrlChange: (UrlChange change) {
            // debugPrint('[$runtimeType] Url change to ${change.url}');
          },
          onPageStarted: (String url) {
            // debugPrint('[$runtimeType] Page started loading: $url');
          },
          onProgress: (int progress) {
            debugPrint('[$runtimeType] WebView is loading $progress%');
          },
          onPageFinished: (String url) async {
            debugPrint('[$runtimeType] Page finished loading: $url');
            await _runJavascript(projectId);
          },
        ),
      )
      ..addJavaScriptChannel('message', onMessageReceived: _onMessageReceived)
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        debugPrint('[$runtimeType] Console ${message.message}');
      })
      ..loadHtmlString(_htmlString);

    try {
      // enable inspector
      final webKitController = controller.platform as WebKitWebViewController;
      webKitController.setInspectable(true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Future<void> connectEmail(String email) async {
  //   final message = MagicMessage(
  //     type: '@w3m-app/CONNECT_EMAIL',
  //     payload: {'email': email},
  //   );
  //   final stringMessage = jsonEncode(message.toJson());
  //   debugPrint('[$runtimeType] Sending $stringMessage');
  //   await controller.runJavaScript('''
  //             var iframe = document.getElementById('w3m-iframe');
  //             iframe.contentWindow.postMessage($stringMessage, '*')
  //         ''');
  // }

  void _onMessageReceived(JavaScriptMessage message) async {
    debugPrint('[$runtimeType] Received ${message.message}');
    try {
      final messageMap = MagicMessage.fromJson(jsonDecode(message.message));
      if (messageMap.type == '@w3m-app/INITIALIZED') {
        //
      }
      if (messageMap.type == '@w3m-app/FRAME_LOADED') {
        checkIsConnected();
      }
      if (messageMap.type.contains('@w3m-frame/IS_CONNECTED')) {
        final hasError = messageMap.type != '@w3m-frame/IS_CONNECTED_SUCCESS';
        onInit?.call(error: hasError);
      }
      if (messageMap.type == '@w3m-frame/CONNECT_EMAIL_ERROR') {
        connectDevice();
      }
    } catch (e) {
      debugPrint('[$runtimeType] error $message $e');
      onInit?.call(error: true);
    }
  }

  Future<void> checkIsConnected() async {
    await controller.runJavaScript('checkConnected()');
  }

  Future<void> connectEmail(String email) async {
    await controller.runJavaScript('connectEmail(\'$email\')');
  }

  Future<void> connectDevice() async {
    await controller.runJavaScript('connectDevice()');
  }

  Future<void> _runJavascript(String projectId) async {
    await controller.runJavaScript('''

      let provider;
      import('https://esm.sh/@web3modal/smart-account@3.4.0-e3959a31').then((package) => {
        provider = new package.W3mFrameProvider('$projectId')
        window.message.postMessage(JSON.stringify($_initialized), '*')
      });

      const checkConnected = async () => {
        // const { isConnected } = await provider.isConnected();
        // window.postMessage(JSON.stringify({ isConnected }))
        iframeO.contentWindow.postMessage($_appConnected, '*')
      }

      const connectEmail = async (email) => {
        // const { action } = await provider.connectEmail({ email })
        // window.postMessage(JSON.stringify({ action }))
        iframeO.contentWindow.postMessage({type: '@w3m-app/CONNECT_EMAIL', payload: {email: email}}, '*')
      }

      const connectDevice = async (email) => {
        // const { action } = await provider.connectDevice()
        // window.postMessage(JSON.stringify({ action }))
        iframeO.contentWindow.postMessage({type: '@w3m-app/CONNECT_DEVICE'}, '*')
      }

      const iframeO = document.createElement('iframe')
      iframeO.id = 'w3m-iframe'
      iframeO.src = '$_url'
      document.body.appendChild(iframeO)

      iframeO.onload = () => {
        window.message.postMessage(JSON.stringify($_frameLoaded), '*')

        window.addEventListener('message', ({ data }) => {
          window.message.postMessage(JSON.stringify(data), '*')
        })

        // iframeO.contentWindow.postMessage($_appConnected, '*')
      }

      iframeO.onerror = () => {
        window.message.postMessage(JSON.stringify($_frameError), '*')
      }
    ''');
  }
}

const _initialized = '{type: \'@w3m-app/INITIALIZED\'}';
const _frameLoaded = '{type: \'@w3m-app/FRAME_LOADED\'}';
const _frameError = '{type: \'@w3m-frame/ERROR\'}';
const _appConnected = '{type: \'@w3m-app/IS_CONNECTED\'}';

const _htmlString = '''
<html>
<body>
</body>
</html>
''';

class MagicMessage {
  String type;
  Map<String, dynamic>? payload;
  String? rt;
  String? jwt;

  MagicMessage({
    required this.type,
    this.payload,
    this.rt,
    this.jwt,
  });

  factory MagicMessage.fromJson(Map<String, dynamic> json) {
    debugPrint('json ${json}');
    return MagicMessage(
      type: json['type'],
      payload: json['payload'] as Map<String, dynamic>?,
      rt: json['rt'],
      jwt: json['jwt'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {'type': type};
    debugPrint('payload ${payload}');
    if ((payload ?? {}).isNotEmpty) {
      params['payload'] = payload;
    }
    if ((rt ?? '').isNotEmpty) {
      params['rt'] = rt;
    }
    if ((jwt ?? '').isNotEmpty) {
      params['jwt'] = jwt;
    }

    return params;
  }
}
