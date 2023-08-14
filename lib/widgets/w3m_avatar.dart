import 'package:flutter/material.dart';
import 'package:walletconnect_modal_flutter/walletconnect_modal_flutter.dart';
import 'package:web3modal_flutter/utils/util.dart';

class W3MAvatar extends StatelessWidget {
  const W3MAvatar({
    super.key,
    required this.address,
    this.avatar,
    this.size = 40.0,
  });

  final String? avatar;
  final String address;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: avatar != null
            ? Image.network(avatar!)
            : _buildGradientAvatar(context),
      ),
    );
  }

  Widget _buildGradientAvatar(BuildContext context) {
    List<Color> colors = Util.generateAvatarColors(address);
    WalletConnectModalThemeData themeData =
        WalletConnectModalTheme.getData(context);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: colors[0],
            borderRadius: BorderRadius.circular(size / 2.0),
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
}
