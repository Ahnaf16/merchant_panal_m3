import 'package:flutter/material.dart';

import 'package:merchant_m3/core/core.dart';

class PopupMenuTile<T> extends PopupMenuEntry<T> {
  const PopupMenuTile({
    super.key,
    this.value,
    this.onTap,
    this.enabled = true,
    this.padding,
    this.textStyle,
    this.labelTextStyle,
    this.mouseCursor,
    required this.child,
    this.icon,
    this.warn = false,
    this.height = kMinInteractiveDimension,
  });

  final T? value;
  final VoidCallback? onTap;
  final bool enabled;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final MaterialStateProperty<TextStyle?>? labelTextStyle;
  final MouseCursor? mouseCursor;
  final Widget? child;
  final IconData? icon;
  final bool warn;

  @override
  final double height;

  @override
  PopupMenuTileState<T, PopupMenuTile<T>> createState() =>
      PopupMenuTileState<T, PopupMenuTile<T>>();

  @override
  bool represents(T? value) => value == this.value;
}

class PopupMenuTileState<T, W extends PopupMenuTile<T>> extends State<W> {
  @protected
  Widget? buildChild() => Row(
        children: [
          if (widget.icon != null)
            Icon(
              widget.icon!,
              color: widget.warn ? context.colorTheme.onError : null,
              size: 18,
            ),
          if (widget.icon != null) const SizedBox(width: 10),
          if (widget.child != null) widget.child!,
        ],
      );

  @protected
  void handleTap() {
    widget.onTap?.call();
    Navigator.pop<T>(context, widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final PopupMenuThemeData defaults = _PopupMenuDefaultsM3(context);

    final Set<MaterialState> states = <MaterialState>{
      if (!widget.enabled) MaterialState.disabled,
    };

    TextStyle style = widget.labelTextStyle?.resolve(states) ??
        popupMenuTheme.labelTextStyle?.resolve(states)! ??
        defaults.labelTextStyle!.resolve(states)!;

    if (!widget.enabled && !theme.useMaterial3) {
      style = style.copyWith(color: theme.disabledColor);
    }

    Widget item = AnimatedDefaultTextStyle(
      style: widget.warn
          ? style.copyWith(color: context.colorTheme.onError)
          : style,
      duration: kThemeChangeDuration,
      child: Container(
        color: widget.warn ? context.colorTheme.error : null,
        alignment: AlignmentDirectional.centerStart,
        constraints: BoxConstraints(minHeight: widget.height),
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
        child: buildChild(),
      ),
    );

    return MergeSemantics(
      child: Semantics(
        enabled: widget.enabled,
        button: true,
        child: InkWell(
          onTap: widget.enabled ? handleTap : null,
          canRequestFocus: widget.enabled,
          child: item,
        ),
      ),
    );
  }
}

class _PopupMenuDefaultsM3 extends PopupMenuThemeData {
  _PopupMenuDefaultsM3(this.context) : super(elevation: 3.0);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  MaterialStateProperty<TextStyle?>? get labelTextStyle {
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      final TextStyle style = _textTheme.labelLarge!;
      if (states.contains(MaterialState.disabled)) {
        return style.apply(color: _colors.onSurface.withOpacity(0.38));
      }
      return style.apply(color: _colors.onSurface);
    });
  }

  @override
  Color? get color => _colors.surface;

  @override
  Color? get shadowColor => _colors.shadow;

  @override
  Color? get surfaceTintColor => _colors.surfaceTint;

  @override
  ShapeBorder? get shape => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)));
}
