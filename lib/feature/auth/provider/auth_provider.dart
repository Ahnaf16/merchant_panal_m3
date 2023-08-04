import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/feature/auth/model/auth_state_model.dart';

User? get getUser => FirebaseAuth.instance.currentUser;

final passVisibilityProvider = StateProvider.autoDispose<bool>((ref) {
  return true;
});

final authStateChangeProvider = StreamProvider.autoDispose<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authStateProvider = Provider.autoDispose<AuthState>((ref) {
  final stateChanges = ref.watch(authStateChangeProvider);

  final AuthState state = stateChanges.when(
    data: (data) => data == null
        ? const AuthState.unauthenticated()
        : const AuthState.authenticated(),
    error: (err, st) => const AuthState.unauthenticated(),
    loading: () => const AuthState.loading(),
  );
  return state;
});
