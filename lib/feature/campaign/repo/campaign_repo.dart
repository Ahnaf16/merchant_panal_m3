import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:merchant_m3/core/const/firebase_const.dart';
import 'package:merchant_m3/core/util/failure.dart';
import 'package:merchant_m3/models/models.dart';

final campaignRepoProvider = Provider.autoDispose<CampaignRepo>((ref) {
  return CampaignRepo();
});

class CampaignRepo {
  final _fire = FirebaseFirestore.instance;

  CollectionReference get _coll => _fire.collection(FirePath.campaign);

  Future<CampaignModel> getCampaign(String title) async {
    final doc = await _coll.doc(title).get();
    final campaign = CampaignModel.fromDoc(doc);

    return campaign;
  }

  Future<List<CampaignItemModel>> getCampaignItems(String title) async {
    final doc = await _coll.doc(title).collection(title).get();
    final products = doc.docs.map((e) => CampaignItemModel.fromDoc(e)).toList();

    return products;
  }

  FutureEither<bool> addCampaign(CampaignStateModel campaign) async {
    try {
      final batch = _fire.batch();
      final doc = _coll.doc(campaign.campaign.title);
      final itemDoc = doc.collection(campaign.campaign.title);

      batch.set(doc, campaign.campaign.toMap());
      for (var product in campaign.products) {
        batch.set(itemDoc.doc(), product.toMap());
      }
      await batch.commit();
      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<bool> updateCampaign(CampaignStateModel campaign) async {
    try {
      final batch = _fire.batch();
      final doc = _coll.doc(campaign.campaign.title);
      final itemDoc = doc.collection(campaign.campaign.title);

      batch.update(doc, campaign.campaign.toMap());
      for (var product in campaign.removedProducts) {
        batch.delete(itemDoc.doc(product));
      }
      await batch.commit();
      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<bool> updatePriority(CampaignModel campaign, bool isUp) async {
    try {
      final batch = _fire.batch();
      final doc = _coll.doc(campaign.title);

      var preority = isUp ? (campaign.priority + 1) : (campaign.priority - 1);
      final updated = campaign.copyWith(preority: preority);

      batch.update(doc, updated.toMap());

      await batch.commit();
      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<bool> deleteCampaign(String id) async {
    try {
      final batch = _fire.batch();
      final doc = _coll.doc(id);
      final itemDoc = await doc.collection(id).get();

      batch.delete(doc);
      for (var doc in itemDoc.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }
}
