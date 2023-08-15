import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:sign/home_page.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = true;
  List<Color> primaryColors = [
    WalletConnectModalThemeData.darkMode.primary100,
    WalletConnectModalThemeData.darkMode.primary090,
    WalletConnectModalThemeData.darkMode.primary080,
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    LoggerUtil.setLogLevel(Level.verbose);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final WalletConnectModalThemeData themeData = _isDark
        ? WalletConnectModalThemeData.darkMode
        : WalletConnectModalThemeData.lightMode;
    return WalletConnectModalTheme(
      data: themeData.copyWith(
        primary100: primaryColors[0],
        primary090: primaryColors[1],
        primary080: primaryColors[2],
      ),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              const MyHomePage(),
              Positioned(
                bottom: 20,
                right: 20,
                child: Row(
                  children: [
                    _buildIconButton(
                      Icons.theater_comedy_outlined,
                      _swapTheme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _swapTheme() {
    setState(() {
      _isDark = !_isDark;
      if (_isDark &&
          primaryColors[0] == WalletConnectModalThemeData.darkMode.primary100) {
        primaryColors = [
          WalletConnectModalThemeData.lightMode.primary100,
          WalletConnectModalThemeData.lightMode.primary090,
          WalletConnectModalThemeData.lightMode.primary080,
        ];
      } else if (!_isDark &&
          primaryColors[0] ==
              WalletConnectModalThemeData.lightMode.primary100) {
        primaryColors = [
          WalletConnectModalThemeData.darkMode.primary100,
          WalletConnectModalThemeData.darkMode.primary090,
          WalletConnectModalThemeData.darkMode.primary080,
        ];
      }
    });
  }

  Widget _buildIconButton(IconData icon, void Function()? onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(
          48,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
        ),
        iconSize: 24,
        onPressed: onPressed,
      ),
    );
  }
}
