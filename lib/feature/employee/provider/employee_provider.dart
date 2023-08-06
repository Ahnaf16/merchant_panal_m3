import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/auth/provider/auth_provider.dart';
import 'package:merchant_m3/models/models.dart';

final employeeListProvider = StreamProvider<List<EmployeeModel>>((ref) async* {
  final fire = FirebaseFirestore.instance;
  final snap = fire
      .collection(FirePath.appConfig)
      .doc(FirePath.employess)
      .collection(FirePath.employee)
      .snapshots();

  yield* snap
      .map((event) => event.docs.map((e) => EmployeeModel.fromDoc(e)).toList());
});

final loggedInEmployeeProvider = StreamProvider<EmployeeModel>((ref) {
  final fire = FirebaseFirestore.instance;

  final uid = getUser?.uid;

  if (uid == null) return Stream.error('No user');

  final doc = fire
      .collection(FirePath.appConfig)
      .doc(FirePath.employess)
      .collection(FirePath.employee)
      .doc(uid)
      .snapshots();

  return doc.map((e) => EmployeeModel.fromDoc(e));
});

final permissionProvider = Provider<EmployeeModel?>((ref) {
  final employeeData = ref.watch(loggedInEmployeeProvider);

  final employee = employeeData.when(
    loading: () {
      log('loading');
      return null;
    },
    error: (e, s) {
      log('error : $e');
      return null;
    },
    data: (data) {
      log('data : ${data.name}');
      return data;
    },
  );

  return employee;
});
