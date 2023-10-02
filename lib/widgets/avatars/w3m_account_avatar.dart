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
          child: _avatarUrl != null
              ? Image.network(_avatarUrl!)
              : _buildGradientAvatar(context),
        ),
      ),
    );
  }

  Widget _buildGradientAvatar(BuildContext context) {
    if ((_address ?? '').isEmpty) return const SizedBox.shrink();
    List<Color> colors = Util.generateAvatarColors(_address!);
    final themeColors = Web3ModalTheme.colorsOf(context);
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
                color: themeColors.grayGlass025,
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
      _gradient(colors[1], colors[0], const Alignment(-0.75, 0.46)),
      _gradient(colors[2], colors[0], const Alignment(0.3, 0.6)),
      _gradient(colors[3], colors[0], const Alignment(-0.4, 0.7)),
      _gradient(colors[4], colors[0], const Alignment(0.7, 0.3)),
    ];
  }

  Widget _gradient(Color color, Color baseColor, Alignment alignment) {
    const double size = 0.75;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color, color.withOpacity(0.0)],
            stops: const [0.0, size / 4, size],
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
