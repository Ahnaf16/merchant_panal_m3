import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

final themeManagerProvider =
    StateNotifierProvider<ThemeManagerNotifier, ThemeMode>((ref) {
  return ThemeManagerNotifier().._init();
});

class ThemeManagerNotifier extends StateNotifier<ThemeMode> {
  ThemeManagerNotifier() : super(ThemeMode.system);

  final String _boxName = 'theme';
  final String _key = 'isDark';

  setThemeMode(ThemeMode mode) async {
    final box = await _box();

    final isDark = switch (mode) {
      ThemeMode.system => null,
      ThemeMode.dark => true,
      ThemeMode.light => false,
    };

    await box.put(_key, isDark);

    await _init();
  }

  Future<Box<dynamic>> _box() async {
    await Hive.openBox(_boxName);
    return Hive.box(_boxName);
  }

  _init() async {
    final box = await _box();

    final bool? isDark = box.get(_key);

    final res = switch (isDark) {
      null => ThemeMode.system,
      true => ThemeMode.dark,
      false => ThemeMode.light,
    };

    state = res;
  }
}

extension ThemeEx on ThemeMode {
  IconData get icon => switch (this) {
        ThemeMode.system => MdiIcons.themeLightDark,
        ThemeMode.dark => Icons.dark_mode_rounded,
        ThemeMode.light => Icons.light_mode_rounded,
      };
}
