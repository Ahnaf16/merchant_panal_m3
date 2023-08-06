import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/auth/model/auth_state_model.dart';
import 'package:merchant_m3/feature/auth/repo/auth_repo.dart';
import 'package:merchant_m3/feature/employee/provider/employee_provider.dart';

final authCtrlProvider =
    StateNotifierProvider.autoDispose<AuthApiNotifier, AuthState>(
        (ref) => AuthApiNotifier(ref));

class AuthApiNotifier extends StateNotifier<AuthState> {
  AuthApiNotifier(this._ref) : super(const AuthState.unauthenticated());

  final Ref _ref;
  final _auth = FirebaseAuth.instance;
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  AuthRepo get _repo => _ref.watch(authRepoProvider);

  devLogin() async {
    emailCtrl.text = 'dev@gng.com';
    passCtrl.text = 'aaaaaa';
    await login();
  }

  login() async {
    if (emailCtrl.text.isEmpty) {
      Toaster.show('Insert Email');
      return 0;
    }
    if (!emailCtrl.text.isEmail) {
      Toaster.show('Insert valid Email');
      return 0;
    }
    if (passCtrl.text.isEmpty) {
      Toaster.show('Insert Password');
      return 0;
    }
    state = const AuthState.loading();

    final res = await _repo.login(emailCtrl.text, passCtrl.text);

    res.fold(
      (l) => Toaster.show(l.message),
      (r) => state = r,
    );
    return _ref.refresh(loggedInEmployeeProvider);
  }

  Future<void> logOut() async {
    await _auth.signOut();
    state = const AuthState.unauthenticated();
    Toaster.show('Logged Out');
    return _ref.refresh(loggedInEmployeeProvider);
  }
}
