import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    LoggerUtil.setLogLevel(LogLevel.error);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Web3ModalTheme(
      data:
          _isDark ? Web3ModalThemeData.darkMode : Web3ModalThemeData.lightMode,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SizedBox(
          width: double.infinity,
          child: MyHomePage(
            swapTheme: () => setState(() => _isDark = !_isDark),
          ),
        ),
      ),
    );
  }
}
