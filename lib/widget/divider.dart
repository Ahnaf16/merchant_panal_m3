import 'package:flutter/material.dart';

import 'package:gngm/core/core.dart';

class KDivider extends StatelessWidget {
  const KDivider({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
  });
  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 30,
      child: Center(
        child: Container(
          height: thickness ?? 5,
          margin: EdgeInsetsDirectional.only(
            start: indent ?? context.width / 3,
            end: endIndent ?? context.width / 3,
          ),
          decoration: BoxDecoration(
            color: context.colorTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class KVerticalDivider extends StatelessWidget {
  const KVerticalDivider({
    super.key,
    this.width,
    this.height,
    this.thickness,
  });

  final double? width;
  final double? height;
  final double? thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: thickness ?? 1,
      height: height ?? 20,
      margin: EdgeInsets.symmetric(horizontal: width ?? 10),
      decoration: BoxDecoration(
        color: context.colorTheme.onSurface,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
