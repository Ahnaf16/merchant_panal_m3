import 'package:cloud_firestore/cloud_firestore.dart';

class BkashPaymentModel {
  BkashPaymentModel({
    required this.paymentId,
    required this.trxId,
    required this.paymentDate,
    required this.isPartial,
  });

  factory BkashPaymentModel.fromMap(Map<String, dynamic> map) {
    return BkashPaymentModel(
      paymentId: map['paymentId'] ?? '',
      trxId: map['trxId'] ?? '',
      paymentDate: (map['paymentDate'] as Timestamp).toDate(),
      isPartial: map.containsKey('isPartial') ? map['isPartial'] : false,
    );
  }

  factory BkashPaymentModel.fromDoc(DocumentSnapshot doc) {
    return BkashPaymentModel(
      paymentId: doc['paymentId'] ?? '',
      trxId: doc['trxId'] ?? '',
      paymentDate: (doc['paymentDate'] as Timestamp).toDate(),
      isPartial: doc['isPartial'],
    );
  }

  final bool isPartial;
  final DateTime paymentDate;
  final String paymentId;
  final String trxId;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{}
      ..addAll({'paymentId': paymentId})
      ..addAll({'trxId': trxId})
      ..addAll({'paymentDate': paymentDate})
      ..addAll({'isPartial': isPartial});

    return result;
  }

  BkashPaymentModel copyWith({
    DateTime? paymentDate,
    String? paymentId,
    String? trxId,
    bool? isPartial,
  }) {
    return BkashPaymentModel(
      paymentDate: paymentDate ?? this.paymentDate,
      paymentId: paymentId ?? this.paymentId,
      trxId: trxId ?? this.trxId,
      isPartial: isPartial ?? this.isPartial,
    );
  }
}
