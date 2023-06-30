import 'package:flutter/material.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class ThemeSwap extends StatefulWidget {
  const ThemeSwap({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ThemeSwap> createState() => _ThemeSwapState();
}

class _ThemeSwapState extends State<ThemeSwap> {
  bool _isDark = true;
  List<Color> primaryColors = [
    WalletConnectModalThemeData.darkMode.primary100,
    WalletConnectModalThemeData.darkMode.primary090,
    WalletConnectModalThemeData.darkMode.primary080,
  ];

  @override
  Widget build(BuildContext context) {
    final WalletConnectModalThemeData themeData = _isDark
        ? WalletConnectModalThemeData.darkMode
        : WalletConnectModalThemeData.lightMode;
    return Web3ModalTheme(
      data: themeData.copyWith(
        primary100: primaryColors[0],
        primary090: primaryColors[1],
        primary080: primaryColors[2],
      ),
      child: Stack(
        children: [
          widget.child,
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
