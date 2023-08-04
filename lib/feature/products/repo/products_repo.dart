import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gngm/core/const/firebase_const.dart';
import 'package:gngm/core/util/failure.dart';
import 'package:gngm/models/models.dart';

final productsRepoProvider = Provider.autoDispose<ProductsRepo>((ref) {
  return ProductsRepo();
});

class ProductsRepo {
  final _fire = FirebaseFirestore.instance;
  int limit = 20;

  Query get _coll =>
      _fire.collection(FirePath.products).orderBy('date', descending: true);

  FutureEither<Stream<List<ProductModel>>> fetchProducts() async {
    try {
      final snap = _coll.limit(limit).snapshots();
      final items = snap.map((snapshot) =>
          snapshot.docs.map((doc) => ProductModel.fromDoc(doc)).toList());

      return right(items);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<Stream<List<ProductModel>>> fetchNextBatch(
    ProductModel last, {
    String? category,
  }) async {
    try {
      final snap = _coll
          .where('category', isEqualTo: category)
          .limit(limit)
          .startAfter([last.date]).snapshots();

      final items = snap.map((snapshot) =>
          snapshot.docs.map((doc) => ProductModel.fromDoc(doc)).toList());

      return right(items);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<Stream<List<ProductModel>>> search(String quarry) async {
    final snap = _coll.snapshots();

    try {
      final items = snap.map(
        (snapshot) => snapshot.docs
            .where(
              (DocumentSnapshot doc) => doc['name']
                  .toString()
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .contains(quarry.toLowerCase().replaceAll(' ', '')),
            )
            .map((DocumentSnapshot doc) => ProductModel.fromDoc(doc))
            .toList(),
      );
      return right(items);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<bool> addProduct(ProductModel product) async {
    try {
      final ref = _fire.collection(FirePath.products).doc(product.id);

      await ref.set(product.toMap());
      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<bool> updateProduct(ProductModel product) async {
    try {
      final batch = _fire.batch();
      final doc = _fire.collection(FirePath.products).doc(product.id);

      batch.update(doc, product.toMap());

      final cartGroup = await _fire
          .collectionGroup(FirePath.carts)
          .where('productId', isEqualTo: product.id)
          .get();

      final cartDocs = cartGroup.docs.map((e) => e.reference).toList();

      for (var cartDoc in cartDocs) {
        batch.update(cartDoc, CartModel.fromProduct(product).toMap());
      }

      await batch.commit();

      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<bool> deleteProduct(String id) async {
    try {
      final batch = _fire.batch();
      final doc = _fire.collection(FirePath.products).doc(id);

      batch.delete(doc);

      final cartGroup = await _fire
          .collectionGroup(FirePath.carts)
          .where('productId', isEqualTo: id)
          .get();

      final cartDocs = cartGroup.docs.map((e) => e.reference).toList();

      for (var cartDoc in cartDocs) {
        batch.delete(cartDoc);
      }

      await batch.commit();
      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }
}
