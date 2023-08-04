import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/widget/widget.dart';
import 'package:routemaster/routemaster.dart';

extension RouteEx on BuildContext {
  NavigationResult pushTo(String path, {Map<String, String>? query}) =>
      Routemaster.of(this).push(path, queryParameters: query);

  Future<bool> rPop([dynamic obj]) => Routemaster.of(this).pop(obj);

  RouteData get currentRoute => Routemaster.of(this).currentRoute;
  RouteHistory get routeHistory => Routemaster.of(this).history;
  String? queries(String key) => currentRoute.queryParameters[key];
}

extension ContextEx on BuildContext {
  MediaQueryData get mq => MediaQuery.of(this);
  ThemeData get theme => Theme.of(this);

  double get height => mq.size.height;

  double get width => mq.size.width;

  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorTheme => theme.colorScheme;

  Brightness get bright => theme.brightness;

  bool get isDark => bright == Brightness.dark;
  bool get isLight => bright == Brightness.light;

  get pop => Navigator.canPop(this) ? Navigator.pop(this) : null;

  showLoader() => WidgetsBinding.instance.addPostFrameCallback(
        (d) => OverlayLoader(this).show(),
      );

  showInfo(String info, {Function()? onTap, bool autoDismiss = false}) =>
      OverlayLoader(this)
          .showInfo(info, onTap: onTap, autoDismiss: autoDismiss);

  showError(String error) => OverlayLoader(this).showError(error);

  showSuccess(String success) => OverlayLoader(this).showSuccess(success);

  removeLoader() => OverlayLoader(this).remove();

  restartApp() => RestartWidget.restartApp(this);

  get removeFocus {
    FocusScopeNode currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      log('removed');
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}

extension LayoutEx on BuildContext {
  bool get isSmall => Breakpoints.small.isActive(this);
  bool get isMid => Breakpoints.medium.isActive(this);
  bool get isLarge => Breakpoints.largeDesktop.isActive(this);

  int get kCrossAxisCount {
    if (isSmall) return 2;
    if (isMid) return 3;
    return 5;
  }

  int crossAxisCustom(int small, int mid, int large) {
    if (isSmall) return small;
    if (isMid) return mid;
    return large;
  }

  double adaptiveWidth({double? small, double? mid, double? large}) {
    if (isLarge) return large ?? width / 2.5;

    if (isMid) return mid ?? width / 2;

    return small ?? width;
  }

  double adaptiveHeight({double? small, double? mid, double? large}) {
    if (isLarge) return large ?? height / 2;

    if (isMid) return mid ?? height / 1.5;

    return small ?? height;
  }
}
