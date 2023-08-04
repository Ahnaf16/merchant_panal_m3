// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gngm/models/models.dart';

class EmployeeModel {
  EmployeeModel({
    required this.email,
    required this.isDev,
    required this.name,
    required this.password,
    required this.permissions,
    required this.uid,
    required this.photo,
  });

  factory EmployeeModel.fromDoc(DocumentSnapshot doc) {
    return EmployeeModel(
      name: doc['name'],
      uid: doc['uid'],
      permissions: List<EPermissions>.from(
        doc['permissions'].map((x) => EPermissions.fromMap(x)),
      ),
      email: doc['email'],
      password: doc['password'],
      isDev: doc['isDev'],
      photo: doc['photo'] ?? '',
    );
  }

  static EmployeeModel empty = EmployeeModel(
    name: '',
    uid: '',
    permissions: [],
    email: '',
    password: '',
    photo: '',
    isDev: false,
  );

  final String email;
  final bool isDev;
  final String name;
  final String password;
  final List<EPermissions> permissions;
  final String photo;
  final String uid;

  EmployeeModel copyWith({
    String? email,
    bool? isDev,
    String? name,
    String? password,
    List<EPermissions>? permissions,
    String? uid,
    String? photo,
  }) {
    return EmployeeModel(
      email: email ?? this.email,
      isDev: isDev ?? this.isDev,
      name: name ?? this.name,
      password: password ?? this.password,
      permissions: permissions ?? this.permissions,
      uid: uid ?? this.uid,
      photo: photo ?? this.photo,
    );
  }

  bool can(EPermissions permission) {
    return isDev ? true : permissions.contains(permission);
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'email': email});
    result.addAll({'isDev': isDev});
    result.addAll({'name': name});
    result.addAll({'password': password});
    result.addAll({'permissions': permissions.map((x) => x.name).toList()});
    result.addAll({'uid': uid});
    result.addAll({'photo': photo});

    return result;
  }
}
