import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  void init() {
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
          onWebResourceError: _onWebResourceError,
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
            await controller.runJavaScript('''
              console.log('PAGE LOADED')

              const iframeO = document.createElement('iframe')
              iframeO.id = 'w3m-iframe'
              iframeO.src = '$_url'
              document.body.appendChild(iframeO)

              iframeO.onload = () => {
                console.log('FRAME LOADED')

                window.addEventListener('message', ({ data }) => {
                  window.message.postMessage(JSON.stringify(data))
                })

                iframeO.contentWindow.postMessage($_appConnected, '*')
              }

              iframeO.onerror = () => {
                window.message.postMessage(JSON.stringify($_frameError))
              }
            ''');
          },
        ),
      )
      ..addJavaScriptChannel('message', onMessageReceived: _onMessageReceived)
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        debugPrint('[$runtimeType] Console ${message.message}');
      })
      ..loadHtmlString(_htmlString);
  }

  Future<void> connectEmail(String email) async {
    final message = MagicMessage(
      type: '@w3m-app/CONNECT_EMAIL',
      payload: {'email': email},
    );
    final stringMessage = jsonEncode(message.toJson());
    debugPrint('[$runtimeType] Sending $stringMessage');
    await controller.runJavaScript('''
              var iframe = document.getElementById('w3m-iframe');
              iframe.contentWindow.postMessage($stringMessage, '*')
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

  void _onMessageReceived(JavaScriptMessage message) async {
    debugPrint('[$runtimeType] Received ${message.message}');
    try {
      final messageMap = MagicMessage.fromJson(jsonDecode(message.message));
      if (messageMap.type.contains('@w3m-frame/IS_CONNECTED')) {
        final hasError = messageMap.type != '@w3m-frame/IS_CONNECTED_SUCCESS';
        onInit?.call(error: hasError);
      }
    } catch (e) {
      debugPrint('[$runtimeType] error $message $e');
      onInit?.call(error: true);
    }
  }
}

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

  factory MagicMessage.fromJson(Map<String, dynamic> json) => MagicMessage(
        type: json['type'],
        payload: json['payload'],
        rt: json['rt'],
        jwt: json['jwt'],
      );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {'type': type};
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
