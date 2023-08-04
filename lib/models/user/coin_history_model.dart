import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CoinHistoryModel {
  CoinHistoryModel({
    required this.amount,
    required this.date,
    required this.type,
    required this.title,
  });

  factory CoinHistoryModel.fromDoc(DocumentSnapshot doc) {
    return CoinHistoryModel(
      amount: doc['amount'] ?? 0,
      date: (doc['date'] as Timestamp).toDate(),
      title: doc['title'] ?? '',
      type: TransactionType.fromMap(doc['type']),
    );
  }

  final int amount;
  final DateTime date;
  final String title;
  final TransactionType type;

  CoinHistoryModel copyWith({
    int? amount,
    DateTime? date,
    TransactionType? type,
    String? title,
  }) {
    return CoinHistoryModel(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      title: title ?? this.title,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'amount': amount});
    result.addAll({'date': date});
    result.addAll({'type': type.toMap()});
    result.addAll({'title': title});

    return result;
  }

  static CoinHistoryModel postPurchaseHistory(int amount) => CoinHistoryModel(
        amount: amount,
        date: DateTime.now(),
        title: 'Post Purchase',
        type: TransactionType.earned,
      );
}

enum TransactionType {
  redeemed,
  earned;

  IconData get icon {
    final map = {
      redeemed: Icons.remove_rounded,
      earned: Icons.add_rounded,
    };
    return map[this] ?? Icons.help_outline_rounded;
  }

  Color get color {
    final map = {
      redeemed: Colors.red,
      earned: Colors.green,
    };
    return map[this] ?? Colors.red;
  }

  String toMap() => name;

  static TransactionType fromMap(String type) => values.byName(type);
}
