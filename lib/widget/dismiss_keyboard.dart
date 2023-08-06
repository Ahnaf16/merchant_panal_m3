import 'package:flutter/material.dart';
import 'package:merchant_m3/core/core.dart';

class DismissKeyboard extends StatelessWidget {
  final Widget child;
  const DismissKeyboard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.removeFocus,
      child: child,
    );
  }
}
