import 'package:flutter/material.dart';

import 'package:walletconnect_flutter_dapp/home_page.dart';

import 'package:web3modal_flutter/web3modal_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  var _web3modalThemeData = Web3ModalThemeData.lightMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LoggerUtil.setLogLevel(LogLevel.error);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      setState(() {
        final platformDispatcher = View.of(context).platformDispatcher;
        final platformBrightness = platformDispatcher.platformBrightness;
        if (platformBrightness == Brightness.dark) {
          _web3modalThemeData = Web3ModalThemeData.darkMode;
        } else {
          _web3modalThemeData = Web3ModalThemeData.lightMode;
        }
      });
    }
    super.didChangePlatformBrightness();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Web3ModalTheme(
      data: _web3modalThemeData,
      child: MaterialApp(
        title: 'Flutter Demo',
        home: SizedBox(
          width: double.infinity,
          child: MyHomePage(swapTheme: () => _swapTheme()),
        ),
      ),
    );
  }

  void _swapTheme() {
    setState(() {
      if (_web3modalThemeData == Web3ModalThemeData.darkMode) {
        _web3modalThemeData = Web3ModalThemeData.lightMode;
      } else {
        _web3modalThemeData = Web3ModalThemeData.darkMode;
      }
    });
  }
}
