import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:merchant_m3/core/const/firebase_const.dart';
import 'package:merchant_m3/core/util/failure.dart';
import 'package:merchant_m3/models/models.dart';

final flashRepoProvider = Provider.autoDispose<FlashRepo>((ref) {
  return FlashRepo();
});

class FlashRepo {
  final _fire = FirebaseFirestore.instance;

  CollectionReference get _coll => _fire
      .collection(FirePath.flash)
      .doc(FirePath.flash)
      .collection(FirePath.flash);

  FutureEither<Stream<List<FlashModel>>> fetchFlashProducts() async {
    try {
      final docs = _coll.orderBy('priority').snapshots();

      final flashes = docs.map(
          (snap) => snap.docs.map((doc) => FlashModel.fromDoc(doc)).toList());

      return right(flashes);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<String> addFlash(FlashModel flash) async {
    try {
      await _coll.doc(flash.id).set(flash.toMap());
      return right('Flash Added');
    } on FirebaseException catch (e) {
      log(e.toString());
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<String> updateFlash(FlashModel flash) async {
    try {
      await _coll.doc(flash.id).update(flash.toMap());

      return right('Flash Updated');
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<String> updatePriority(
      FlashModel newFlash, FlashModel oldFlash) async {
    try {
      final batch = _fire.batch();
      final newDoc = _coll.doc(newFlash.id);
      final oldDoc = _coll.doc(oldFlash.id);
      final newUpdated = newFlash.copyWith(priority: oldFlash.priority);
      final oldUpdated = oldFlash.copyWith(priority: newFlash.priority);
      batch.update(newDoc, newUpdated.toMap());
      batch.update(oldDoc, oldUpdated.toMap());

      await batch.commit();
      return right('Priority Updated');
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<String> deleteFlash(String id) async {
    try {
      await _coll.doc(id).delete();
      return right('Flash Deleted');
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }
}
