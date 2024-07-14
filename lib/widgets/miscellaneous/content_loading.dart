import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/loader.dart';

class ContentLoading extends StatelessWidget {
  const ContentLoading({super.key, this.viewHeight});
  final double? viewHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: viewHeight ?? 300.0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularLoader(),
        ),
      ),
    );
  }
}
