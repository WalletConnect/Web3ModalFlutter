import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';

class RoundedIcon extends StatelessWidget {
  const RoundedIcon({
    super.key,
    this.assetPath,
    this.imageUrl,
    this.assetColor,
    this.circleColor,
    this.borderColor,
    this.size = 34.0,
    this.padding = 8.0,
    this.borderRadius,
  });
  final String? assetPath, imageUrl;
  final Color? assetColor, circleColor, borderColor;
  final double size, padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final projectId = explorerService.instance.projectId;
    final radius = borderRadius ?? size;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: Border.fromBorderSide(
          BorderSide(
            color: borderColor ?? themeColors.grayGlass005,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        color: circleColor ?? themeColors.grayGlass010,
      ),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl ?? '').isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(radius)),
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.fill,
                fadeInDuration: const Duration(milliseconds: 500),
                fadeOutDuration: const Duration(milliseconds: 500),
                httpHeaders: coreUtils.instance.getAPIHeaders(projectId),
                errorWidget: (context, url, error) => ColoredBox(
                  color: themeColors.grayGlass005,
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(padding),
              child: SvgPicture.asset(
                colorFilter: ColorFilter.mode(
                  assetColor ?? themeColors.foreground200,
                  BlendMode.srcIn,
                ),
                assetPath ?? 'assets/icons/coin.svg',
                package: 'web3modal_flutter',
                width: size,
                height: size,
              ),
            ),
    );
  }
}
