import 'package:flutter/material.dart';
import 'package:gngm/core/core.dart';

class SquaredButton extends StatelessWidget {
  const SquaredButton({
    super.key,
    required this.icon,
    this.title,
    this.onTap,
    this.style,
  });

  final IconData icon;
  final String? title;
  final Function()? onTap;
  final ButtonStyle? style;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            style: style ??
                IconButton.styleFrom(
                  backgroundColor: context.colorTheme.surfaceVariant,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
            onPressed: onTap,
            icon: Icon(icon),
          ),
          if (title != null) const SizedBox(height: 2),
          if (title != null)
            Flexible(
              child: Text(
                title!,
                style: context.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
