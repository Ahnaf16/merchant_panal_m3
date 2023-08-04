import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/models/models.dart';

final employeeRepoProvider = Provider<EmployeeRepo>((ref) {
  return EmployeeRepo();
});

class EmployeeRepo {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<EmployeeModel> getEmployee(String id) async {
    final doc = await _coll().doc(id).get();
    final employee = EmployeeModel.fromDoc(doc);
    return employee;
  }

  FutureEither<String> createEmployee(EmployeeModel employee) async {
    try {
      final authCred = await _auth.createUserWithEmailAndPassword(
        email: employee.email,
        password: employee.password,
      );

      final user = authCred.user;

      if (user == null) return left(const Failure('Unable to create User'));

      await user.updateDisplayName(employee.name);
      await user.updatePhotoURL(employee.photo);

      employee = employee.copyWith(uid: user.uid);

      final ref = _coll().doc(user.uid);

      await ref.set(employee.toMap());

      return right('Employee Created');
    } on FirebaseAuthException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<String> updateEmployee(EmployeeModel employee) async {
    try {
      employee = employee.copyWith(uid: employee.uid);

      final ref = _coll().doc(employee.uid);

      await ref.update(employee.toMap());

      return right('Employee Updated');
    } on FirebaseAuthException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<String> deleteEmployee(String id) async {
    try {
      final ref = _coll().doc(id);
      await ref.delete();

      return right('Employee Deleted');
    } on FirebaseAuthException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  CollectionReference _coll() => _fire
      .collection(FirePath.appConfig)
      .doc(FirePath.employess)
      .collection(FirePath.employee);

  instantLogin(EmployeeModel employee) async {
    await _auth.signOut();
    await _auth.signInWithEmailAndPassword(
      email: employee.email,
      password: employee.password,
    );
    Toaster.show('Logged In as ${employee.name}');
  }
}
