import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_dapp/home_page.dart';
import 'package:walletconnect_flutter_dapp/utils/string_constants.dart';
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
  bool _isDarkMode = false;
  Web3ModalThemeData? _themeData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        final platformDispatcher = View.of(context).platformDispatcher;
        final platformBrightness = platformDispatcher.platformBrightness;
        _isDarkMode = platformBrightness == Brightness.dark;
      });
    });
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
        _isDarkMode = platformBrightness == Brightness.dark;
      });
    }
    super.didChangePlatformBrightness();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Web3ModalTheme(
      isDarkMode: _isDarkMode,
      themeData: _themeData,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: StringConstants.w3mPageTitleV3,
        home: MyHomePage(
          toggleTheme: () => _toggleTheme(),
          toggleBrightness: () => _toggleBrightness(),
        ),
      ),
    );
  }

  void _toggleTheme() => setState(() {
        _themeData = (_themeData == null) ? _customTheme : null;
      });

  void _toggleBrightness() => setState(() {
        _isDarkMode = !_isDarkMode;
      });

  Web3ModalThemeData get _customTheme => Web3ModalThemeData(
        lightColors: Web3ModalColors.lightMode.copyWith(
          accent100: const Color.fromARGB(255, 30, 59, 236),
          background100: const Color.fromARGB(255, 161, 183, 231),
          // Main Modal's background color
          background125: const Color.fromARGB(255, 206, 221, 255),
          background175: const Color.fromARGB(255, 237, 241, 255),
          inverse100: const Color.fromARGB(255, 233, 237, 236),
          inverse000: const Color.fromARGB(255, 22, 18, 19),
          // Main Modal's text
          foreground100: const Color.fromARGB(255, 22, 18, 19),
          // Secondary Modal's text
          foreground150: const Color.fromARGB(255, 22, 18, 19),
        ),
        darkColors: Web3ModalColors.darkMode.copyWith(
          accent100: const Color.fromARGB(255, 161, 183, 231),
          background100: const Color.fromARGB(255, 30, 59, 236),
          // Main Modal's background color
          background125: const Color.fromARGB(255, 12, 23, 99),
          background175: const Color.fromARGB(255, 78, 103, 230),
          inverse100: const Color.fromARGB(255, 22, 18, 19),
          inverse000: const Color.fromARGB(255, 233, 237, 236),
          // Main Modal's text
          foreground100: const Color.fromARGB(255, 233, 237, 236),
          // Secondary Modal's text
          foreground150: const Color.fromARGB(255, 233, 237, 236),
        ),
        radiuses: Web3ModalRadiuses.square,
      );
}
