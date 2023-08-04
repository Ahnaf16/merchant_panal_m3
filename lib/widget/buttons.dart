import 'package:flutter/material.dart';
import 'package:gngm/core/core.dart';

class SmallCircularButton extends StatelessWidget {
  const SmallCircularButton({
    super.key,
    this.onTap,
    required this.icon,
    this.padding,
  });

  final Function()? onTap;
  final IconData icon;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(180),
      splashColor: context.colorTheme.secondary,
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorTheme.secondaryContainer,
        ),
        child: Icon(
          icon,
          color: context.colorTheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
