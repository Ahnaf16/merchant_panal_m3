import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/auth/ctrl/auth_ctrl.dart';
import 'package:gngm/feature/auth/model/auth_state_model.dart';
import 'package:gngm/feature/auth/provider/auth_provider.dart';
import 'package:gngm/widget/widget.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authCtrlProvider);
    final authCtrl = ref.read(authCtrlProvider.notifier);
    final isPassVisible = ref.watch(passVisibilityProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: AdaptiveBody(
            height: context.adaptiveHeight(large: context.height / 1.5),
            width: context.adaptiveWidth(
              large: context.width / 1.5,
              mid: context.width / 1.2,
            ),
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (!context.isSmall)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Assets.logoLogo.image(
                              height: 100,
                              width: 100,
                            ),
                            const SizedBox(height: 20),
                            Text.rich(
                              TextSpan(
                                text: 'Welcome to \n',
                                style: context.textTheme.titleLarge?.copyWith(
                                  height: 1.8,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Gadget N Gadget Merchant',
                                    style:
                                        context.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      height: 1.8,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                  if (!context.isSmall) const VerticalDivider(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SIGN IN',
                            style: context.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: authCtrl.emailCtrl,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: authCtrl.passCtrl,
                            obscureText: isPassVisible,
                            keyboardType: TextInputType.visiblePassword,
                            onSubmitted: (value) => authCtrl.login(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPassVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                                onPressed: () {
                                  ref
                                      .read(passVisibilityProvider.notifier)
                                      .update((state) => !state);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (authState == const AuthState.loading())
                            const CircularProgressIndicator()
                          else
                            FilledButton(
                              onPressed: () async {
                                await authCtrl.login();
                              },
                              child: const Text('SIGN IN'),
                            ),
                          const SizedBox(height: 30),
                          if (kDebugMode)
                            OutlinedButton.icon(
                              onPressed: () async => await authCtrl.devLogin(),
                              icon: const Icon(Icons.developer_mode_rounded),
                              label: const Text('DEV LOGIN'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
