import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/models/models.dart';

final orderDetailsProvider =
    StreamProvider.autoDispose.family<OrderModel, String?>((ref, id) async* {
  if (id == null) {
    throw Exception('Not found');
  }
  final fire = FirebaseFirestore.instance;
  final doc = fire.collection(FirePath.orders).doc(id).snapshots();
  final order = doc.map((snapshot) => OrderModel.fromDoc(snapshot));
  yield* order;
});

final orderCountProvider = StreamProvider<Map<OrderStatus, int>>((ref) async* {
  final firestore = FirebaseFirestore.instance;
  Map<OrderStatus, int> counts = {};

  final values = OrderStatus.values
      .where((e) => e != OrderStatus.duplicate && e != OrderStatus.cancelled)
      .toList();

  for (final status in values) {
    final query = await firestore
        .collection(FirePath.orders)
        .where('status', isEqualTo: status.title)
        .count()
        .get();

    counts.addAll({status: query.count});
  }
  counts[OrderStatus.all] = counts.values.sum;
  yield counts;
});
