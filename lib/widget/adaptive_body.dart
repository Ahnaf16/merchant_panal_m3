import 'package:flutter/material.dart';

import 'package:merchant_m3/core/core.dart';

class AdaptiveBody extends StatelessWidget {
  const AdaptiveBody({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width ??
            context.adaptiveWidth(
              large: context.width / 1.5,
              mid: context.width / 1.3,
            ),
        height: height,
        child: child,
      ),
    );
  }
}
