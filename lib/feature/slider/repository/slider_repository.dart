import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:merchant_m3/models/slider/slider_model.dart';

import '../../../core/const/firebase_const.dart';
import '../../../core/util/failure.dart';

final sliderRepoProvider = Provider.autoDispose<SliderRepository>((ref) {
  return SliderRepository();
});

class SliderRepository {
  final _fire = FirebaseFirestore.instance;
  CollectionReference get _coll => _fire.collection(FirePath.slider);

  FutureEither<String> addSlider(SliderModel slider) async {
    try {
      final doc = _coll.doc(slider.id);

      await doc.set(slider.toMap());

      return right('Slider Added');
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<bool> deleteSlider(String id) async {
    try {
      final doc = _coll.doc(id);
      await doc.delete();
      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }
}
