import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/utils/util.dart';

class W3MAvatar extends StatefulWidget {
  const W3MAvatar({
    super.key,
    required this.service,
    this.size = 40.0,
  });

  final IW3MService service;
  final double size;

  @override
  State<W3MAvatar> createState() => _W3MAvatarState();
}

class _W3MAvatarState extends State<W3MAvatar> {
  String? _avatarUrl;
  String? _address;

  @override
  void initState() {
    super.initState();
    widget.service.addListener(_w3mServiceUpdated);
    _w3mServiceUpdated();
  }

  @override
  void dispose() {
    widget.service.removeListener(_w3mServiceUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: _avatarUrl != null
            ? Image.network(_avatarUrl!)
            : _buildGradientAvatar(context),
      ),
    );
  }

  Widget _buildGradientAvatar(BuildContext context) {
    List<Color> colors = Util.generateAvatarColors(_address!);
    WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: colors[0],
            borderRadius: BorderRadius.circular(widget.size / 2.0),
            boxShadow: [
              BoxShadow(
                color: themeData.overlay030,
                spreadRadius: 1.0,
                blurRadius: 0.0,
              ),
            ],
          ),
        ),
        ..._buildGradients(colors),
      ],
    );
  }

  List<Widget> _buildGradients(List<Color> colors) {
    return [
      _gradient(colors[1], const Alignment(0.32, 0.54)),
      _gradient(colors[2], const Alignment(-0.42, 0.94)),
      _gradient(colors[3], const Alignment(0.98, 0.72)),
      _gradient(colors[4], const Alignment(-0.42, 0.76)),
    ];
  }

  Widget _gradient(Color color, Alignment alignment) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
            stops: const [0.0, 0.5],
            center: alignment,
          ),
        ),
      ),
    );
  }

  void _w3mServiceUpdated() {
    setState(() {
      _avatarUrl = widget.service.avatarUrl;
      _address = widget.service.address;
    });
  }
}
