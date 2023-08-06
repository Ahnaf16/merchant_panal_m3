import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/const/firebase_const.dart';
import 'package:merchant_m3/models/models.dart';

final flashProvider = StreamProvider<List<FlashModel>>((ref) {
  final firestore = FirebaseFirestore.instance;

  final docs = firestore
      .collection(FirePath.flash)
      .doc(FirePath.flash)
      .collection(FirePath.flash);
  final snap = docs.snapshots();

  return snap.map(
    (snapshot) => snapshot.docs.map((doc) => FlashModel.fromDoc(doc)).toList(),
  );
});
