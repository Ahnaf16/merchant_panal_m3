import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;

class Failure {
  const Failure(
    this.message, {
    this.stackTrace,
  });

  Failure.fromFirebase(
    FirebaseException fireException, {
    this.stackTrace,
  }) : message = fireException.message ??
            'Something Gone Wrong `${fireException.code}`';

  Failure.fromException(
    Exception? exception, {
    this.stackTrace,
  }) : message = exception?.toString() ?? 'Something Gone Wrong';

  final String message;
  final StackTrace? stackTrace;

  Failure copyWith({
    String? message,
    StackTrace? stackTrace,
  }) {
    return Failure(
      message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  String toString() {
    return 'Failure(\nmessage: $message,\n stackTrace: $stackTrace\n)';
  }
}
