import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/slider/slider_model.dart';

final sliderListProvider = StreamProvider.autoDispose<List<SliderModel>>((ref) {
  final fire = FirebaseFirestore.instance;
  final snap = fire.collection('slider').snapshots();
  return snap.map((snapshot) {
    return snapshot.docs.map((doc) {
      return SliderModel.fromDoc(doc);
    }).toList();
  });
});
