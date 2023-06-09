import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/grid_list/grid_list.dart';

class WalletImage extends StatelessWidget {
  const WalletImage({
    super.key,
    required this.imageUrl,
    this.imageSize = GridList.tileSize,
  });

  final String imageUrl;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          GridList.getTileBorderRadius(imageSize),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(imageUrl),
    );
  }
}
