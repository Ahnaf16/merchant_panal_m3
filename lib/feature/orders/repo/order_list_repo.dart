import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/models/models.dart';

final ordersRepoProvider = Provider.autoDispose<OrdersRepo>((ref) {
  return OrdersRepo();
});

class OrdersRepo {
  final _fire = FirebaseFirestore.instance;
  int limit = 20;

  CollectionReference get _coll => _fire.collection(FirePath.orders);

  Query _filteringQuery(OrderPageState state) => _coll
      .orderBy('orderDate', descending: true)
      .where('status', isEqualTo: state.status.valueFilter?.title)
      .where('paymentMethod', isEqualTo: state.payment.valueFilter?.title)
      .where('orderDate', isGreaterThanOrEqualTo: state.dateRange?.start)
      .where(
        'orderDate',
        isLessThanOrEqualTo: state.dateRange?.end.add(1.days),
      );

  FutureEither<Stream<List<OrderModel>>> fetchOrders() async {
    try {
      final snap =
          _coll.orderBy('orderDate', descending: true).limit(limit).snapshots();
      final orders = snap.map((snapshot) =>
          snapshot.docs.map((doc) => OrderModel.fromDoc(doc)).toList());
      return right(orders);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<OrderModel> fetchOrderWithID(String id) async {
    try {
      final doc = await _coll.doc(id).get();

      final order = OrderModel.fromDoc(doc);
      return right(order);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<Stream<List<OrderModel>>> fetchNextBatch(
    OrderModel last, {
    required OrderPageState state,
  }) async {
    try {
      final snap = _filteringQuery(state)
          .limit(limit)
          .startAfter([last.orderDate]).snapshots();

      final orders = snap.map((snapshot) =>
          snapshot.docs.map((doc) => OrderModel.fromDoc(doc)).toList());

      return right(orders);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<Stream<List<OrderModel>>> filter(
    OrderPageState state,
    String query,
  ) async {
    try {
      final parsedQuery = _searchParser(query).$1;
      final searchField = _searchParser(query).$2;

      final snap = query.isEmpty
          ? _filteringQuery(state).limit(limit).snapshots()
          : _coll.where(searchField, isEqualTo: parsedQuery).snapshots();

      final orders = snap.map((snapshot) =>
          snapshot.docs.map((docs) => OrderModel.fromDoc(docs)).toList());
      return right(orders);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<String> addNewOrder(OrderModel order) async {
    try {
      final doc = _coll.doc();
      await doc.set(order.toMap());
      return right('Order placed');
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<String> updateOrder(OrderModel order) async {
    try {
      final batch = _fire.batch();
      final doc = _coll.doc(order.docID);

      batch.update(doc, order.toMap());

      final doseStatusContains =
          order.timeLine.map((e) => e.status).contains(OrderStatus.shipped);

      final canGiftCoin = switch (order.status) {
        OrderStatus.shipped when !doseStatusContains => true,
        _ => false,
      };
      if (canGiftCoin) {
        final userDoc = _fire.collection(FirePath.users).doc(order.user.uid);
        final historyPath = userDoc.collection(FirePath.coinHistory).doc();

        await _fire.runTransaction((transaction) async {
          final userSnap = await transaction.get(userDoc);

          UserModel user = UserModel.fromDoc(userSnap);

          user =
              user.copyWith(gCoin: user.gCoin + _coinEarning(order.subTotal));

          transaction.update(userDoc, user.toMap());
        });

        final history =
            CoinHistoryModel.postPurchaseHistory(_coinEarning(order.subTotal));

        batch.set(historyPath, history.toMap());
      }
      await batch.commit();
      return right('Order Updated');
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<String> deleteOrder(String orderId) async {
    try {
      final doc = _coll.doc(orderId);
      await doc.delete();
      return right('Order Deleted');
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  (String, String) _searchParser(String query) {
    if (query.isEmpty) return ('', '');

    if (query.isPhone) {
      return query.contains('+88')
          ? (query.replaceAll('+88', ''), 'address.billingNumber')
          : (query, 'address.billingNumber');
    } else {
      if (query.toUpperCase().startsWith('#GNG')) {
        return (query.toUpperCase(), 'invoice');
      }
      if (!query.contains('#') && query.toUpperCase().contains('GNG')) {
        return ('#${query.toUpperCase()}', 'invoice');
      }

      return ('#GNG$query', 'invoice');
    }
  }

  int _coinEarning(int spendAmount) {
    if (spendAmount <= 1000) return 50;
    if (spendAmount <= 2000) return 100;
    if (spendAmount <= 5000) return 200;
    if (spendAmount <= 10000) return 400;
    if (spendAmount <= 20000) return 500;
    return 700;
  }
}
