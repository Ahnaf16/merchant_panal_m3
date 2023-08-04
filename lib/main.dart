import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/firebase_options.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:routemaster/routemaster.dart';

import 'core/util/restart.dart';
import 'routes/route_config.dart';
import 'theme/color_schemes.dart';
import 'theme/custom_color.dart';
import 'theme/theme_manager.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Routemaster.setPathUrlStrategy();
  runApp(const ProviderScope(child: MyApp()));
  FlutterNativeSplash.remove();
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routeProvider);
    final themeMode = ref.watch(themeManagerProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          lightCustomColors = lightCustomColors.harmonized(lightScheme);
          darkScheme = darkDynamic.harmonized();
          darkCustomColors = darkCustomColors.harmonized(darkScheme);
        } else {
          lightScheme = FallbackColor.lightColorScheme;
          darkScheme = FallbackColor.darkColorScheme;
        }

        return RefreshConfiguration(
          headerBuilder: () => const ClassicHeader(),
          child: RestartWidget(
            child: MaterialApp.router(
              // showSemanticsDebugger: true,
              debugShowCheckedModeBanner: false,
              title: 'Merchant',
              themeMode: themeMode,
              theme: themeData(lightScheme, false),
              darkTheme: themeData(darkScheme, true),
              routeInformationParser: const RoutemasterParser(),
              routerDelegate: routes,
            ),
          ),
        );
      },
    );
  }

  ThemeData themeData(ColorScheme colorScheme, bool isDark) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [if (isDark) darkCustomColors else lightCustomColors],
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(filled: true),
      ),
    );
  }
}
