import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gngm/core/util/failure.dart';
import 'package:gngm/feature/auth/model/auth_state_model.dart';

final authRepoProvider = Provider<AuthRepo>((ref) {
  return AuthRepo();
});

class AuthRepo {
  final _auth = FirebaseAuth.instance;
  FutureEither<AuthState> login(String email, String pass) async {
    try {
      final userCred =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);

      final user = userCred.user;

      if (user == null) {
        return left(const Failure('Login was unsuccessful'));
      }

      return right(const AuthState.authenticated());
    } on FirebaseAuthException catch (e) {
      log(e.message.toString(), name: 'auth');
      return left(Failure(e.message ?? 'Something went wrong'));
    }
  }
}
