import 'package:flutter/material.dart';

import 'package:gngm/core/extensions/context_extension.dart';

class DualText extends StatelessWidget {
  const DualText({
    super.key,
    required this.left,
    required this.right,
    this.onTap,
    this.icon,
    this.warn = false,
  });

  final String left;
  final String right;
  final IconData? icon;
  final Function()? onTap;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              style: context.textTheme.bodyLarge,
              children: [
                if (icon != null)
                  WidgetSpan(
                    child: Icon(icon, size: 18),
                    alignment: PlaceholderAlignment.middle,
                  ),
                TextSpan(text: ' $left'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 1),
          Flexible(
            flex: 3,
            child: Text(
              right,
              style: context.textTheme.bodyLarge?.copyWith(
                color: warn ? context.colorTheme.error : null,
                fontWeight: warn ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
