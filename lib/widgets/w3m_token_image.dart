import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hexagon/hexagon.dart';

class W3MTokenImage extends StatelessWidget {
  const W3MTokenImage({
    super.key,
    this.imageUrl,
    this.isChain = false,
    this.size = 36,
  });

  final String? imageUrl;
  final double size;
  final bool isChain;

  @override
  Widget build(BuildContext context) {
    return isChain ? _buildChain() : _buildToken();
  }

  Widget _buildToken() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(
            100,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? SvgPicture.asset(
              'assets/token_placeholder.svg',
              package: 'web3modal_flutter',
              width: size,
              height: size,
            )
          : Image.network(
              imageUrl!,
              width: size,
              height: size,
            ),
    );
  }

  Widget _buildChain() {
    return HexagonWidget.pointy(
      width: size,
      height: size,
      cornerRadius: 8,
      color: Colors.black,
      child: imageUrl == null
          ? SvgPicture.asset(
              'assets/network_placeholder.svg',
              package: 'web3modal_flutter',
              width: size,
              height: size,
            )
          : Image.network(
              imageUrl!,
              width: size,
              height: size,
            ),
    );
  }
}
