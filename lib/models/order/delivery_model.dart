import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryChargeModel {
  const DeliveryChargeModel({
    required this.accessoryInside,
    required this.accessoryOutside,
    required this.phnInside,
    required this.phnOutside,
    required this.haveDelivery,
  });

  factory DeliveryChargeModel.fromDoc(DocumentSnapshot doc) {
    return DeliveryChargeModel(
      phnInside: doc['phnInside'] as int,
      phnOutside: doc['phnOutside'] as int,
      accessoryInside: doc['accessoryInside'] as int,
      accessoryOutside: doc['accessoryOutside'] as int,
      haveDelivery: doc['haveDelivery'] as bool,
    );
  }

  static DeliveryChargeModel empty = const DeliveryChargeModel(
    phnInside: 0,
    phnOutside: 0,
    accessoryInside: 0,
    accessoryOutside: 0,
    haveDelivery: true,
  );

  final int accessoryInside;
  final int accessoryOutside;
  final bool haveDelivery;
  final int phnInside;
  final int phnOutside;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'accessoryInside': accessoryInside});
    result.addAll({'accessoryOutside': accessoryOutside});
    result.addAll({'haveDelivery': haveDelivery});
    result.addAll({'phnInside': phnInside});
    result.addAll({'phnOutside': phnOutside});

    return result;
  }

  DeliveryChargeModel copyWith({
    int? accessoryInside,
    int? accessoryOutside,
    bool? haveDelivery,
    int? phnInside,
    int? phnOutside,
  }) {
    return DeliveryChargeModel(
      accessoryInside: accessoryInside ?? this.accessoryInside,
      accessoryOutside: accessoryOutside ?? this.accessoryOutside,
      haveDelivery: haveDelivery ?? this.haveDelivery,
      phnInside: phnInside ?? this.phnInside,
      phnOutside: phnOutside ?? this.phnOutside,
    );
  }
}
