import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

CustomColors lightCustomColors = const CustomColors(
  source: Color(0xFF09C918),
  color: Color(0xFF006E06),
  onColor: Color(0xFFFFFFFF),
  colorContainer: Color(0xFF76FF65),
  onColor1Container: Color(0xFF002201),
);

CustomColors darkCustomColors = const CustomColors(
  source: Color(0xFF09C918),
  color: Color(0xFF3DE437),
  onColor: Color(0xFF003A02),
  colorContainer: Color(0xFF005303),
  onColor1Container: Color(0xFF76FF65),
);

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.source,
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColor1Container,
  });

  final Color? source;
  final Color? color;
  final Color? onColor;
  final Color? colorContainer;
  final Color? onColor1Container;

  @override
  CustomColors copyWith({
    Color? sourceCustomColor1,
    Color? customColor1,
    Color? onCustomColor1,
    Color? customColor1Container,
    Color? onCustomColor1Container,
  }) {
    return CustomColors(
      source: sourceCustomColor1 ?? source,
      color: customColor1 ?? color,
      onColor: onCustomColor1 ?? onColor,
      colorContainer: customColor1Container ?? colorContainer,
      onColor1Container: onCustomColor1Container ?? onColor1Container,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      source: Color.lerp(source, other.source, t),
      color: Color.lerp(color, other.color, t),
      onColor: Color.lerp(onColor, other.onColor, t),
      colorContainer: Color.lerp(colorContainer, other.colorContainer, t),
      onColor1Container:
          Color.lerp(onColor1Container, other.onColor1Container, t),
    );
  }

  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith(
      sourceCustomColor1: source!.harmonizeWith(dynamic.primary),
      customColor1: color!.harmonizeWith(dynamic.primary),
      onCustomColor1: onColor!.harmonizeWith(dynamic.primary),
      customColor1Container: colorContainer!.harmonizeWith(dynamic.primary),
      onCustomColor1Container:
          onColor1Container!.harmonizeWith(dynamic.primary),
    );
  }
}
