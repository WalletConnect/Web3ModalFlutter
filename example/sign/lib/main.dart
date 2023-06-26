import 'package:flutter/material.dart';
import 'package:sign/home_page.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

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
    Web3ModalThemeData.darkMode.primary100,
    Web3ModalThemeData.darkMode.primary090,
    Web3ModalThemeData.darkMode.primary080,
  ];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Web3ModalThemeData themeData =
        _isDark ? Web3ModalThemeData.darkMode : Web3ModalThemeData.lightMode;
    return Web3ModalTheme(
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
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Web3Modal Sign Example'),
          ),
          body: SizedBox(
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
      ),
    );
  }

  void _swapTheme() {
    setState(() {
      _isDark = !_isDark;
      if (_isDark &&
          primaryColors[0] == Web3ModalThemeData.darkMode.primary100) {
        primaryColors = [
          Web3ModalThemeData.lightMode.primary100,
          Web3ModalThemeData.lightMode.primary090,
          Web3ModalThemeData.lightMode.primary080,
        ];
      } else if (!_isDark &&
          primaryColors[0] == Web3ModalThemeData.lightMode.primary100) {
        primaryColors = [
          Web3ModalThemeData.darkMode.primary100,
          Web3ModalThemeData.darkMode.primary090,
          Web3ModalThemeData.darkMode.primary080,
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
