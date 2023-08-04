import 'package:flutter/material.dart';
import 'package:gngm/core/core.dart';

class KDecorated extends StatelessWidget {
  const KDecorated({
    super.key,
    required this.child,
    this.hint,
  });

  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint != null) Text(hint!),
        if (hint != null) const SizedBox(height: 5),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorTheme.surfaceVariant,
            border: Border.all(color: context.colorTheme.onSurfaceVariant),
            borderRadius: BorderRadius.circular(5),
          ),
          child: child,
        ),
      ],
    );
  }
}
