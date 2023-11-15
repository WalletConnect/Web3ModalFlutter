import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/w3m_theme.dart';
import 'package:web3modal_flutter/utils/util.dart';

class W3MAccountAvatar extends StatefulWidget {
  const W3MAccountAvatar({
    super.key,
    required this.service,
    this.size = 40.0,
    this.disabled = false,
  });

  final IW3MService service;
  final double size;
  final bool disabled;

  @override
  State<W3MAccountAvatar> createState() => _W3MAccountAvatarState();
}

class _W3MAccountAvatarState extends State<W3MAccountAvatar> {
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
    final themeColors = Web3ModalTheme.colorsOf(context);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            widget.disabled ? themeColors.foreground300 : Colors.transparent,
            BlendMode.saturation,
          ),
          child: (_avatarUrl ?? '').isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: _avatarUrl!,
                  fadeInDuration: const Duration(milliseconds: 500),
                  fadeOutDuration: const Duration(milliseconds: 500),
                )
              : GradientOrb(address: _address, size: widget.size),
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

class GradientOrb extends StatelessWidget {
  const GradientOrb({
    super.key,
    this.address,
    this.size = 40.0,
  });
  final String? address;
  final double size;

  @override
  Widget build(BuildContext context) {
    List<Color> colors = Util.generateAvatarColors(address);
    final themeColors = Web3ModalTheme.colorsOf(context);
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: colors[4],
            borderRadius: BorderRadius.circular(size / 2.0),
            boxShadow: [
              BoxShadow(
                color: themeColors.grayGlass025,
                spreadRadius: 1.0,
                blurRadius: 0.0,
              ),
            ],
          ),
        ),
        ..._buildGradients(colors..removeAt(4)),
      ],
    );
  }

  List<Widget> _buildGradients(List<Color> colors) {
    double size = 1.5;
    final gradients = colors.reversed.map((c) {
      size -= 0.1;
      return _gradient(c, size);
    }).toList();
    gradients.add(
      _gradient(Colors.white.withOpacity(0.8), 0.5),
    );
    return gradients;
  }

  Widget _gradient(Color color, double size) => Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color, color.withOpacity(0.0)],
              stops: [0.0, size / 4, size],
              center: const Alignment(0.3, -0.3),
            ),
          ),
        ),
      );
}
