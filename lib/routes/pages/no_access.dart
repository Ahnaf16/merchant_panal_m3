import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/auth/ctrl/auth_ctrl.dart';
import 'package:merchant_m3/routes/route_names.dart';

class NoAccessPage extends ConsumerWidget {
  const NoAccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCtrl = ref.read(authCtrlProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton.outlined(
            onPressed: () => authCtrl.logOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.remove_moderator_rounded,
              size: 100,
              color: context.colorTheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'You are not authorized to access this page',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colorTheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: context.colorTheme.error,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go to Home'),
              onPressed: () => context.pushTo(RoutesName.dash),
            )
          ],
        ),
      ),
    );
  }
}
