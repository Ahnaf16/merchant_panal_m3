import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/orders/repo/order_list_repo.dart';
import 'package:gngm/models/models.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final orderListCtrlProvider =
    StateNotifierProvider.autoDispose<OrderListCtrlNotifier, OrderPageState>(
        (ref) {
  return OrderListCtrlNotifier(ref).._init();
});

class OrderListCtrlNotifier extends StateNotifier<OrderPageState> {
  OrderListCtrlNotifier(this._ref) : super(OrderPageState.empty);
  final Ref _ref;
  OrdersRepo get _repo => _ref.read(ordersRepoProvider);

  final refreshCtrl = RefreshController();
  final searchCtrl = TextEditingController();
  final searchFocus = FocusNode();

  @override
  void dispose() {
    refreshCtrl.dispose();
    searchCtrl.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  _init() async {
    final res = await _repo.fetchOrders();

    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => _putData(r),
    );
  }

  reload() async {
    await _init();
    state = state.copyWith(
      payment: PaymentMethods.all,
      status: OrderStatus.all,
      dateRange: () => null,
      loadingMore: false,
      hasMore: true,
    );
    searchCtrl.clear();
    refreshCtrl.loadComplete();
    refreshCtrl.refreshCompleted();
  }

  loadMore() async {
    if (searchCtrl.text.isNotEmpty) return 0;

    final List<OrderModel> stateItem = state.orders.maybeWhen(
      data: (data) => data,
      orElse: () => List.empty(),
    );

    final res = await _repo.fetchNextBatch(stateItem.last, state: state);

    res.fold(
      (l) => Toaster.showFailure(l),
      (r) async {
        await for (final orders in r) {
          state = state.copyWith(orders: AsyncValue.data(stateItem + orders));
          refreshCtrl.loadComplete();
          if (orders.isEmpty) {
            refreshCtrl.loadNoData();
          }
        }
      },
    );
  }

  filter(BuildContext context) async {
    final searchProducts = await _repo.filter(state, searchCtrl.text);

    searchProducts.fold(
      (l) => context.showError(l.message),
      (r) => _putData(r),
    );
  }

  // _stateLoader() => state = state.copyWith(orders: const AsyncValue.loading());

  setOrderStatus(OrderStatus status) => state = state.copyWith(status: status);
  setPayment(PaymentMethods method) => state = state.copyWith(payment: method);
  setDateRange(DateTimeRange? dateRange) =>
      state = state.copyWith(dateRange: () => dateRange);

  clearDateRange() => state = state = state.copyWith(dateRange: () => null);

  _putData(Stream<List<OrderModel>> orderStream) async {
    await for (final orders in orderStream) {
      state = state.copyWith(orders: AsyncValue.data(orders));
    }
  }
}
