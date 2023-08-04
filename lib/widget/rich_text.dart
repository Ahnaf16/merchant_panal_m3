import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  const CustomRichText({
    Key? key,
    required this.text,
    this.rightsymbol,
    this.leftSymbol,
    this.color,
    this.style,
  }) : super(key: key);
  final String text;
  final String? leftSymbol;
  final String? rightsymbol;
  final Color? color;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: leftSymbol,
            style: style == null
                ? TextStyle(color: color)
                : style?.copyWith(color: color),
          ),
          TextSpan(text: text, style: style),
          TextSpan(
            text: rightsymbol,
            style: style == null
                ? TextStyle(color: color)
                : style?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
