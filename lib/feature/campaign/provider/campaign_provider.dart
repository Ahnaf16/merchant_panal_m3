import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/models/models.dart';

final campaignListProvider = StreamProvider<List<CampaignModel>>((ref) {
  final fire = FirebaseFirestore.instance;
  final snap = fire
      .collection(FirePath.campaign)
      .orderBy('priority', descending: true)
      .snapshots();
  return snap.map(
    (snapshot) =>
        snapshot.docs.map((doc) => CampaignModel.fromDoc(doc)).toList(),
  );
});

final campaignItemsProvider =
    StreamProvider.family<List<CampaignItemModel>, String>((ref, title) {
  final FirebaseFirestore fire = FirebaseFirestore.instance;
  final snap = fire
      .collection(FirePath.campaign)
      .doc(title)
      .collection(title)
      .snapshots();

  return snap.map(
    (snapshot) =>
        snapshot.docs.map((doc) => CampaignItemModel.fromDoc(doc)).toList(),
  );
});
