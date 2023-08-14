import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexagon/hexagon.dart';

class W3MTokenImage extends StatelessWidget {
  const W3MTokenImage({
    super.key,
    this.token,
    this.isChain = false,
    this.size = 36,
  });

  final String? token;
  final double size;
  final bool isChain;

  @override
  Widget build(BuildContext context) {
    return isChain ? _buildChain() : _buildToken();
  }

  Widget _buildToken() {
    return token == null
        ? SvgPicture.asset(
            'token_placeholder.svg',
            package: 'web3modal_flutter',
            width: size,
            height: size,
          )
        : Image.network(
            token!,
            width: size,
            height: size,
          );
  }

  Widget _buildChain() {
    return HexagonWidget.pointy(
      width: size,
      cornerRadius: 8,
      child: token == null
          ? SvgPicture.asset(
              'network_placeholder.svg',
              package: 'web3modal_flutter',
              // width: size,
              // height: size,
            )
          : Image.network(
              token!,
              // width: size,
              // height: size,
            ),
    );
  }
}
