import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';
import 'package:web3modal_flutter/version.dart' as w3m;

import 'package:web3modal_flutter/web3modal_flutter.dart';

class DebugDrawer extends StatefulWidget {
  const DebugDrawer({
    super.key,
    required this.toggleOverlay,
    required this.toggleBrightness,
    required this.toggleTheme,
  });
  final VoidCallback toggleOverlay;
  final VoidCallback toggleBrightness;
  final VoidCallback toggleTheme;

  @override
  State<DebugDrawer> createState() => _DebugDrawerState();
}

class _DebugDrawerState extends State<DebugDrawer> with WidgetsBindingObserver {
  late SharedPreferences prefs;
  bool _analyticsValue = false;
  bool _emailWalletValue = false;
  bool _siweAuthValue = false;
  bool _analyticsValueBkp = false;
  bool _emailWalletValueBkp = false;
  bool _siweAuthValueBkp = false;
  bool _hasUpdates = false;

  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      setState(() {});
    }
    super.didChangePlatformBrightness();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SharedPreferences.getInstance().then((instance) {
        setState(() {
          prefs = instance;
          _analyticsValue = prefs.getBool('app_w3m_analytics') ?? true;
          _analyticsValueBkp = _analyticsValue;
          _emailWalletValue = prefs.getBool('app_w3m_email_wallet') ?? true;
          _emailWalletValueBkp = _emailWalletValue;
          _siweAuthValue = prefs.getBool('app_w3m_siwe_auth') ?? true;
          _siweAuthValueBkp = _siweAuthValue;
        });
      });
    });
  }

  void _updateValue(String key, bool value) async {
    await prefs.setBool(key, value);
    _hasUpdates = true;
    setState(() {});
  }

  Future<void> _restore() async {
    await prefs.setBool('app_w3m_analytics', _analyticsValueBkp);
    await prefs.setBool('app_w3m_email_wallet', _emailWalletValueBkp);
    await prefs.setBool('app_w3m_siwe_auth', _siweAuthValueBkp);
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = Web3ModalTheme.isCustomTheme(context);
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.logo_dev_rounded,
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                  title: const Text('Analytics view'),
                  titleTextStyle: TextStyle(
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                  onTap: () {
                    widget.toggleOverlay();
                  },
                ),
                ListTile(
                  leading: isCustom
                      ? Icon(
                          Icons.yard,
                          color: Web3ModalTheme.colorsOf(context).foreground100,
                        )
                      : Icon(
                          Icons.yard_outlined,
                          color: Web3ModalTheme.colorsOf(context).foreground100,
                        ),
                  title: isCustom
                      ? const Text('Custom theme')
                      : const Text('Default theme'),
                  titleTextStyle: TextStyle(
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                  trailing: Switch(
                    value: isCustom,
                    activeColor: Web3ModalTheme.colorsOf(context).accent100,
                    onChanged: (value) {
                      widget.toggleTheme();
                    },
                  ),
                ),
                ListTile(
                  leading: Web3ModalTheme.maybeOf(context)?.isDarkMode ?? false
                      ? Icon(
                          Icons.dark_mode_outlined,
                          color: Web3ModalTheme.colorsOf(context).foreground100,
                        )
                      : Icon(
                          Icons.light_mode_outlined,
                          color: Web3ModalTheme.colorsOf(context).foreground100,
                        ),
                  title: Web3ModalTheme.maybeOf(context)?.isDarkMode ?? false
                      ? const Text('Dark theme')
                      : const Text('Light theme'),
                  titleTextStyle: TextStyle(
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                  trailing: Switch(
                    value: Web3ModalTheme.maybeOf(context)?.isDarkMode ?? false,
                    activeColor: Web3ModalTheme.colorsOf(context).accent100,
                    onChanged: (value) {
                      widget.toggleBrightness();
                    },
                  ),
                ),
                const SizedBox.square(dimension: 10.0),
                const Divider(height: 1.0, indent: 12.0, endIndent: 12.0),
                const SizedBox.square(dimension: 10.0),
                Center(
                  child: Text(
                    'Will require app to restart',
                    style: TextStyle(
                      color: Web3ModalTheme.colorsOf(context).foreground100,
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 10.0),
                ListTile(
                  leading: Icon(
                    Icons.speaker_notes_rounded,
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                  title: const Text('Analytics On'),
                  titleTextStyle: TextStyle(
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                  trailing: Switch(
                    value: _analyticsValue,
                    activeColor: Web3ModalTheme.colorsOf(context).accent100,
                    onChanged: (value) {
                      _analyticsValue = value;
                      _updateValue('app_w3m_analytics', value);
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.email_rounded,
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                  title: const Text('Email Wallet On'),
                  titleTextStyle: TextStyle(
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                  trailing: Switch(
                    value: _emailWalletValue,
                    activeColor: Web3ModalTheme.colorsOf(context).accent100,
                    onChanged: (value) {
                      _emailWalletValue = value;
                      _updateValue('app_w3m_email_wallet', value);
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet,
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                  title: const Text('1-CA + SIWE On'),
                  titleTextStyle: TextStyle(
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                  trailing: Switch(
                    value: _siweAuthValue,
                    activeColor: Web3ModalTheme.colorsOf(context).accent100,
                    onChanged: (value) {
                      _siweAuthValue = value;
                      _updateValue('app_w3m_siwe_auth', value);
                    },
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          '${snapshot.data?.packageName} v${snapshot.data?.version ?? ''} (${snapshot.data?.buildNumber})\n'
                          'AppKit v${w3m.packageVersion}\n'
                          'Core v$packageVersion',
                    ),
                  );
                },
                child: Text(
                  '${snapshot.data?.packageName} v${snapshot.data?.version ?? ''} (${snapshot.data?.buildNumber})\n'
                  'AppKit v${w3m.packageVersion}\n'
                  'Core v$packageVersion',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Web3ModalTheme.colorsOf(context).foreground100,
                  ),
                ),
              );
            },
          ),
          const SizedBox.square(dimension: 10.0),
          const Divider(height: 1.0, indent: 12.0, endIndent: 12.0),
          ListTile(
            leading: Icon(
              Icons.close,
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
            title: const Text('Close'),
            titleTextStyle: TextStyle(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
            onTap: () {
              if (_hasUpdates) {
                // TODO warn and crash!
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text(
                          'Application will be closed to make changes'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _restore().then((value) => Navigator.pop(context));
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            exit(0);
                          },
                          child: const Text('Ok'),
                        )
                      ],
                    );
                  },
                );
              } else {
                // restore and pop
                _restore().then((value) => Navigator.pop(context));
              }
            },
          ),
        ],
      ),
    );
  }
}
