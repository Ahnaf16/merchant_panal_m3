import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gngm/core/extensions/context_extension.dart';
import 'package:gngm/core/gen/assets.gen.dart';
import 'package:gngm/widget/shimmer.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.error,
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;

  void logError() => log(
        '${'=====' * 10}\n'
        '> message: $error\n'
        '${stackTrace != null ? '\n${'-----' * 10}\n'
            '> stack Trace: $stackTrace\n' : '\n'}${'=====' * 10}',
      );

  static Widget withScaffold(error, stackTrace) =>
      Scaffold(body: ErrorView(error: error, stackTrace: stackTrace));

  static Widget errorMathod(error, stackTrace) =>
      ErrorView(error: error, stackTrace: stackTrace);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (kDebugMode)
              IconButton(
                icon: const Icon(
                  Icons.bug_report_outlined,
                  size: 25,
                  color: Colors.red,
                ),
                onPressed: () => logError(),
              ),
            if (kDebugMode)
              Text('$error')
            else
              const Text('Something gone wrong !!'),
          ],
        ),
      ),
    );
  }
}

class Loader extends StatelessWidget {
  const Loader({super.key, this.loader});

  final Widget? loader;

  static Widget loading() => const Loader();
  static Widget withScaffold() => const Scaffold(body: Loader());

  static Widget shimmer() => Loader(
        loader: KShimmer.card(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 10),
        ),
      );

  @override
  Widget build(BuildContext context) => Center(
        child: loader ?? Assets.lottieLoading.lottie(height: 60, width: 60),
      );
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: context.textTheme.titleLarge?.copyWith(letterSpacing: 2),
      ),
    );
  }
}
