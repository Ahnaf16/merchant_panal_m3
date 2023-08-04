import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/models/models.dart';

final deliveryRepoProvider = Provider.autoDispose<DeliveryRepo>((ref) {
  return DeliveryRepo();
});

class DeliveryRepo {
  final _fire = FirebaseFirestore.instance;

  DocumentReference get _doc =>
      _fire.collection(FirePath.appConfig).doc(FirePath.deliveryInfo);

  Future<DeliveryChargeModel> getCharges() async {
    final doc = await _doc.get();
    final charge = DeliveryChargeModel.fromDoc(doc);

    return charge;
  }

  FutureEither<String> updateCharges(DeliveryChargeModel charge) async {
    try {
      await _doc.update(charge.toMap());
      return right('Delivery Charge Updated');
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }
}
