import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/models/models.dart';

class OrderTimelineModel extends Equatable {
  const OrderTimelineModel({
    required this.status,
    required this.date,
    required this.comment,
    required this.userName,
  });

  factory OrderTimelineModel.fromMap(Map<String, dynamic> map) {
    return OrderTimelineModel(
      status: OrderStatus.fromString(map['status']),
      date: (map['date'] as Timestamp).toDate(),
      comment: map['comment'],
      userName: map['userName'] ?? 'noName',
    );
  }

  static OrderTimelineModel empty = OrderTimelineModel(
    status: OrderStatus.pending,
    date: DateTime.now(),
    comment: OrderMassage.pending,
    userName: '',
  );

  final String comment;
  final DateTime date;
  final OrderStatus status;
  final String userName;

  Map<String, dynamic> toMap() {
    return {
      'status': status.title,
      'date': date,
      'comment': comment,
      'userName': userName,
    };
  }

  bool get isFirst => status == OrderStatus.pending;
  bool get isLast => status == OrderStatus.cancelled;

  @override
  List<Object?> get props => [comment, date, status, userName];
}
