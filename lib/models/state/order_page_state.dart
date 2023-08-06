import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/models/models.dart';

enum OrderSort {
  orderDate('Order Date'),
  lastMod('Last Modified');

  final String title;
  const OrderSort(this.title);
}

class OrderPageState {
  const OrderPageState({
    required this.orders,
    required this.payment,
    required this.status,
    required this.dateRange,
    required this.loadingMore,
    required this.hasMore,
  });

  final AsyncValue<List<OrderModel>> orders;

  final PaymentMethods payment;
  final OrderStatus status;
  final DateTimeRange? dateRange;
  final bool loadingMore;
  final bool hasMore;

  OrderPageState copyWith({
    AsyncValue<List<OrderModel>>? orders,
    PaymentMethods? payment,
    OrderStatus? status,
    bool? loadingMore,
    bool? hasMore,
    DateTimeRange? Function()? dateRange,
  }) {
    return OrderPageState(
      orders: orders ?? this.orders,
      payment: payment ?? this.payment,
      status: status ?? this.status,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      dateRange: dateRange == null ? this.dateRange : dateRange(),
    );
  }

  static OrderPageState get empty {
    return const OrderPageState(
      orders: AsyncValue.loading(),
      dateRange: null,
      status: OrderStatus.all,
      payment: PaymentMethods.all,
      loadingMore: false,
      hasMore: true,
    );
  }

  DateTime get firstDate => DateTime(2020, 1, 1);
  DateTime get lastDate => DateTime.now().add(1.days);
}
