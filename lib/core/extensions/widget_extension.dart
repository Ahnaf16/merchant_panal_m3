import 'package:flutter/material.dart';
import 'package:gngm/core/core.dart';

extension ButtonEx on IconButton {
  Widget adapt(BuildContext context, [String label = '']) {
    if (context.isSmall) {
      return this;
    } else {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(tooltip ?? label),
        autofocus: autofocus,
        focusNode: focusNode,
        key: key,
      );
    }
  }
}
