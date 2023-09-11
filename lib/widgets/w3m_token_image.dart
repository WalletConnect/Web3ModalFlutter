import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:web3modal_flutter/theme/theme.dart';

class W3MTokenImage extends StatelessWidget {
  const W3MTokenImage({
    super.key,
    this.imageUrl,
    this.isChain = false,
    this.size = 36,
    this.cornerRadius = 0.3,
    this.disabled = false,
  });

  final String? imageUrl;
  final double size;
  final bool isChain;
  final double cornerRadius;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return isChain
        ? _buildChain(context, disabled)
        : _buildToken(context, disabled);
  }

  Widget _buildToken(BuildContext context, bool disabled) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(
            100,
          ),
        ),
        border: Border.fromBorderSide(
          BorderSide(
            color: themeData.colors.overgray020,
            width: 1,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Transform.scale(
        scale: 1.05,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            disabled ? themeData.colors.foreground300 : Colors.transparent,
            BlendMode.saturation,
          ),
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
        ),
      ),
    );
  }

  Widget _buildChain(BuildContext context, bool disabled) {
    final themeData = Web3ModalTheme.getDataOf(context);

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        shape: StarBorder.polygon(
          side: BorderSide(
            color: themeData.colors.overgray020,
            width: 2,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
          pointRounding: 0.4,
          sides: 6,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          disabled ? themeData.colors.foreground300 : Colors.transparent,
          BlendMode.saturation,
        ),
        child: imageUrl == null
            ? Transform.scale(
                scale: 1.25,
                child: SvgPicture.asset(
                  'assets/network_placeholder.svg',
                  package: 'web3modal_flutter',
                  width: size,
                  height: size,
                ),
              )
            : Transform.scale(
                scale: 1.05,
                child: Image.network(
                  imageUrl!,
                  width: size,
                  height: size,
                ),
              ),
      ),
    );
  }
}
