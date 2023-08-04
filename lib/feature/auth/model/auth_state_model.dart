// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

enum AuthStates { unauthenticated, authenticated, loading, error, unknown }

class AuthState extends Equatable {
  const AuthState._({
    this.status = AuthStates.unknown,
  });

  const AuthState.loading() : this._(status: AuthStates.loading);

  const AuthState.authenticated() : this._(status: AuthStates.authenticated);

  const AuthState.unauthenticated()
      : this._(
          status: AuthStates.unauthenticated,
        );

  const AuthState.unknown() : this._();

  final AuthStates status;

  @override
  List<Object?> get props => [status.name];

  @override
  bool get stringify => true;
}
