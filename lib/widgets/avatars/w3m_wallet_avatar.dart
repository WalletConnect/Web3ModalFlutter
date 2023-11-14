import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/core/core_utils_singleton.dart';

class W3MListAvatar extends StatelessWidget {
  const W3MListAvatar({
    super.key,
    this.imageUrl,
    this.borderRadius,
    this.isNetwork = false,
    this.color,
    this.disabled = false,
  });
  final String? imageUrl;
  final double? borderRadius;
  final bool isNetwork;
  final Color? color;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final themeColors = Web3ModalTheme.colorsOf(context);
    final radiuses = Web3ModalTheme.radiusesOf(context);
    final radius = borderRadius ?? radiuses.radiusM;
    final projectId = explorerService.instance?.projectId ?? '';
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: isNetwork
                ? ShapeDecoration(
                    shape: StarBorder.polygon(
                      pointRounding: 0.3,
                      sides: 6,
                    ),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color: themeColors.grayGlass005,
                  ),
            clipBehavior: Clip.antiAlias,
            child: (imageUrl ?? '').isNotEmpty
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      disabled ? Colors.grey : Colors.transparent,
                      BlendMode.saturation,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      httpHeaders: coreUtils.instance.getAPIHeaders(projectId),
                      fadeInDuration: const Duration(milliseconds: 500),
                      fadeOutDuration: const Duration(milliseconds: 500),
                      errorWidget: (context, url, error) => ColoredBox(
                        color: themeColors.grayGlass005,
                      ),
                    ),
                  )
                : ColoredBox(
                    color: themeColors.grayGlass005,
                  ),
          ),
        ),
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: isNetwork
                ? ShapeDecoration(
                    shape: StarBorder.polygon(
                      side: BorderSide(
                        color: color ?? themeColors.grayGlass010,
                        width: 1.0,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      pointRounding: 0.3,
                      sides: 6,
                    ),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: color ?? themeColors.grayGlass010,
                      width: 1.0,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
