import 'package:flutter/material.dart';
import 'package:merchant_m3/core/gen/assets.gen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.info});
  final String? info;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Assets.lottieLoading.lottie(height: 150, width: 150),
      ),
    );
  }
}
