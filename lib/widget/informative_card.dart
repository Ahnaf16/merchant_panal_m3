import 'package:flutter/material.dart';

import 'package:merchant_m3/core/core.dart';

class InformativeCard extends StatelessWidget {
  const InformativeCard({
    super.key,
    required this.header,
    this.headerStyle,
    required this.children,
    this.actions,
    this.useWrap = false,
    this.wrapSpacing = 10,
  });

  final List<Widget>? actions;
  final List<Widget> children;
  final String header;
  final TextStyle? headerStyle;
  final bool useWrap;
  final double wrapSpacing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  header,
                  style: headerStyle ?? context.textTheme.titleLarge,
                ),
                const Spacer(),
                ...?actions,
              ],
            ),
            const SizedBox(height: 10),
            if (useWrap)
              Wrap(
                spacing: wrapSpacing,
                runSpacing: wrapSpacing,
                children: [...children],
              )
            else
              ...children,
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
