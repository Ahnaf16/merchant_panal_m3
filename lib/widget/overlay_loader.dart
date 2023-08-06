import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/theme/custom_color.dart';
import 'package:merchant_m3/widget/widget.dart';

enum SnackType {
  info,
  loading,
  success,

  error;

  Widget widget(Color color) => switch (this) {
        info => _widget(Icons.info_outline_rounded, color),
        success => _widget(Icons.check_rounded, color),
        error => _widget(Icons.error_outline, color),
        loading => const Loader(),
      };

  _widget(IconData icon, Color color) {
    return Center(child: Icon(icon, color: color));
  }
}

class OverlayLoader {
  OverlayLoader(this.context);

  final BuildContext context;
  static bool _onScreen = false;
  static OverlayEntry? _overlayEntry;

  static bool isLoaderOn() => _onScreen;
  final focusNode = FocusNode();

  void show() => _show(message: '', type: SnackType.loading);

  void showError(String error) async {
    _show(message: error, type: SnackType.error);
    await Future.delayed(const Duration(seconds: 5));
    remove();
  }

  void showInfo(String message,
      {Function()? onTap, bool autoDismiss = false}) async {
    _show(message: message, type: SnackType.info, onTap: onTap);
    if (autoDismiss) {
      await Future.delayed(const Duration(seconds: 5));
      remove();
    }
  }

  void showSuccess(String message) async {
    _show(message: message, type: SnackType.success);
    await Future.delayed(const Duration(seconds: 3));
    remove();
  }

  void _show({
    String message = '',
    required SnackType type,
    Function()? onTap,
  }) async {
    FocusScope.of(context).requestFocus(focusNode);
    if (_overlayEntry != null) remove();
    _overlayEntry =
        createOverlayEntry(message: message, type: type, onTap: onTap);

    Overlay.of(context).insert(_overlayEntry!);
    _onScreen = true;
  }

  void remove() {
    if (_onScreen) {
      _overlayEntry!.remove();
      _onScreen = false;
    }
  }

  // Loader can be changed from here
  OverlayEntry createOverlayEntry({
    String message = '',
    Alignment alignment = Alignment.bottomCenter,
    required SnackType type,
    Function()? onTap,
  }) {
    final isLoading = type == SnackType.loading;
    return OverlayEntry(
      builder: (context) => RepaintBoundary(
        child: _OverlayWidget(
          isLoading: isLoading,
          alignment: alignment,
          type: type,
          message: message,
          onClose: () => remove(),
          onTap: onTap,
        ).animate().fadeIn(),
      ),
    );
  }
}

class _OverlayWidget extends StatelessWidget {
  const _OverlayWidget({
    required this.isLoading,
    required this.alignment,
    required this.type,
    required this.message,
    required this.onClose,
    required this.onTap,
  });

  final String message;
  final bool isLoading;
  final SnackType type;
  final Alignment alignment;
  final Function() onClose;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isLoading ? Alignment.center : alignment,
      child: Card(
        elevation: isLoading ? 0 : null,
        color: _getBGColor(context, type),
        margin: const EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: context.height / 15),
          child: isLoading
              ? type.widget(_getFGColor(context, type))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      type.widget(_getFGColor(context, type)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          message,
                          style: context.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getFGColor(context, type),
                          ),
                        ),
                      ),
                      if (onTap != null)
                        IconButton.filled(
                          onPressed: () {
                            onClose();
                            onTap!();
                          },
                          icon: Icon(
                            Icons.file_open_rounded,
                            color: context.colorTheme.primaryContainer,
                          ),
                        ),
                      IconButton.outlined(
                        onPressed: onClose,
                        icon: Icon(
                          Icons.close,
                          color: _getFGColor(context, type),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

Color _getBGColor(BuildContext context, SnackType type) {
  return switch (type) {
    SnackType.loading => Colors.transparent,
    SnackType.info => context.colorTheme.secondaryContainer,
    SnackType.success => context.theme.extension<CustomColors>()!.onColor!,
    SnackType.error => context.colorTheme.error,
  };
}

Color _getFGColor(BuildContext context, SnackType type) {
  return switch (type) {
    SnackType.loading => Colors.transparent,
    SnackType.info => context.colorTheme.onSecondaryContainer,
    SnackType.success => context.theme.extension<CustomColors>()!.color!,
    SnackType.error => context.colorTheme.onError,
  };
}
