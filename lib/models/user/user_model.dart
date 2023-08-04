// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.age,
    required this.createdAt,
    required this.displayName,
    required this.dob,
    required this.email,
    required this.gender,
    required this.loginMethod,
    required this.phone,
    required this.photoUrl,
    required this.totalOrders,
    required this.gCoin,
    required this.uid,
    this.referralCode,
    this.usedReferralCode,
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    return UserModel(
      uid: doc['uid'],
      email: doc['email'],
      phone: doc['phone'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      loginMethod: doc['loginMethod'],
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
      dob: doc['dob'],
      age: doc['age'],
      gender: doc['gender'],
      gCoin: doc.data()!.toString().contains('gCoin') ? doc['gCoin'] : 0,
      totalOrders: doc.data()!.toString().contains('totalOrders')
          ? doc['totalOrders']
          : -1,
      referralCode: doc.data()!.toString().contains('referralCode')
          ? doc['referralCode']
          : null,
      usedReferralCode: doc.data()!.toString().contains('usedReferralCode')
          ? doc['usedReferralCode']
          : null,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'] == 'Email' ? '' : map['email'],
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      displayName: map['displayName'],
      loginMethod: map['loginMethod'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      dob: map['dob'],
      age: map['age'],
      gender: map['gender'],
      totalOrders: map.containsKey('totalOrders') ? map['totalOrders'] : 0,
      gCoin: map.containsKey('gCoin') ? map['gCoin'] : 0,
      referralCode:
          map.containsKey('referralCode') ? map['referralCode'] : null,
      usedReferralCode:
          map.containsKey('referralCode') ? map['referralCode'] : null,
    );
  }

  static UserModel empty = UserModel(
    uid: '',
    email: '',
    phone: '',
    photoUrl: '',
    displayName: '',
    loginMethod: '',
    createdAt: DateTime.now(),
    dob: '',
    age: 0,
    gender: '',
    totalOrders: 0,
    gCoin: 0,
    referralCode: null,
    usedReferralCode: null,
  );

  final int age;
  final DateTime createdAt;
  final String displayName;
  final String dob;
  final String email;
  final int gCoin;
  final String gender;
  final String loginMethod;
  final String phone;
  final String photoUrl;
  final int totalOrders;
  final String uid;
  final String? referralCode;
  final String? usedReferralCode;

  @override
  List<Object> get props => [
        age,
        createdAt,
        displayName,
        dob,
        email,
        gender,
        loginMethod,
        phone,
        photoUrl,
        uid,
      ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'displayName': displayName,
        'loginMethod': loginMethod,
        'createdAt': createdAt,
        'dob': dob,
        'age': age,
        'gender': gender,
        'totalOrders': totalOrders,
        'gCoin': gCoin,
        'referralCode': referralCode,
        'usedReferralCode': usedReferralCode
      };

  UserModel copyWith({
    String? uid,
    String? email,
    String? phone,
    String? photoUrl,
    String? displayName,
    String? loginMethod,
    DateTime? createdAt,
    String? dob,
    int? age,
    String? gender,
    int? totalOrders,
    int? gCoin,
    String? referralCode,
    String? usedReferralCode,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      displayName: displayName ?? this.displayName,
      loginMethod: loginMethod ?? this.loginMethod,
      createdAt: createdAt ?? this.createdAt,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      totalOrders: totalOrders ?? this.totalOrders,
      gCoin: gCoin ?? this.gCoin,
      referralCode: referralCode ?? this.referralCode,
      usedReferralCode: usedReferralCode ?? usedReferralCode,
    );
  }
}
