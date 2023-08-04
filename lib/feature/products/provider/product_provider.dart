import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/models/models.dart';

final productDetailsProvider =
    StreamProvider.autoDispose.family<ProductModel, String?>((ref, id) {
  if (id == null) {
    throw Exception('Not found');
  }
  final fire = FirebaseFirestore.instance;
  final doc = fire.collection(FirePath.products).doc(id).snapshots();
  final item = doc.map((snapshot) => ProductModel.fromDoc(snapshot));

  return item;
});
