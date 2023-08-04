import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/auth/provider/auth_provider.dart';
import 'package:gngm/feature/orders/ctrl/google_shit_ctrl.dart';
import 'package:gngm/feature/orders/ctrl/invoice_download_ctrl.dart';
import 'package:gngm/feature/orders/repo/order_list_repo.dart';
import 'package:gngm/models/models.dart';
import 'package:open_filex/open_filex.dart';

final orderCtrlProvider = StateNotifierProvider.family
    .autoDispose<OrderCtrlNotifier, OrderModel, OrderModel?>((ref, order) {
  return OrderCtrlNotifier(ref, order).._init();
});

class OrderCtrlNotifier extends StateNotifier<OrderModel> {
  OrderCtrlNotifier(this._ref, this._order) : super(_order ?? OrderModel.empty);
  final Ref _ref;
  final OrderModel? _order;
  OrdersRepo get _repo => _ref.read(ordersRepoProvider);

  final statusCommentCtrl = TextEditingController();
  final paidAmountCtrl = TextEditingController(text: '0');

  _init() {
    if (_order != null) {
      state = _order!;
      paidAmountCtrl.text = _order!.paidAmount.toString();
    }
  }

  setOrderStatus(OrderStatus status) {
    if (status == state.status) return 0;

    statusCommentCtrl.text = status.massage;
    final timeLine = OrderTimelineModel(
      status: status,
      date: DateTime.now(),
      comment: statusCommentCtrl.text,
      userName: getUser?.displayName ?? 'noName',
    );
    state = state.copyWith(
      status: status,
      timeLine: [...?_order?.timeLine, timeLine],
    );
  }

  updatePaidAmount(BuildContext context, [bool isFullUpdate = false]) async {
    if (isFullUpdate) paidAmountCtrl.text = state.total.toString();

    state = state.copyWith(paidAmount: paidAmountCtrl.text.asInt);
    _setLastModData();
    final res = await _repo.updateOrder(state);
    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show('Paid Amount Updated'),
    );
    context.pop;
  }

  updateOrderStatus(BuildContext context) async {
    _setLastModData();
    final res = await _repo.updateOrder(state);
    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show('Status Updated'),
    );
    context.pop;
  }

  _setLastModData() {
    state = state.copyWith(
      lastMod: DateTime.now(),
      lastModBy: getUser?.displayName ?? 'noName',
    );
  }

  addToGoogleSheet(BuildContext context) async {
    final gSheetCtrl = _ref.read(gSheetCtrlProvider.notifier);

    final res = await gSheetCtrl.addOrderToGSheet(state);

    res.fold(
      (l) => context.showError(l.message),
      (r) => context.showSuccess(r),
    );
    context.pop;
  }

  downloadInvoice(BuildContext context) async {
    final pdfCtrl = _ref.watch(pdfCtrlProvider);
    final res = await pdfCtrl.savePdf(state);
    res.fold(
      (l) => context.showError(l.message),
      (r) => context.showInfo(
        'Invoice Download',
        onTap: kIsWeb ? null : () => OpenFilex.open(r, type: 'application/pdf'),
      ),
    );
  }

  openInvoice(BuildContext context) async {
    final pdfCtrl = _ref.watch(pdfCtrlProvider);
    final res = await pdfCtrl.openPdf(state);
    res.fold(
      (l) => context.showError(l.message),
      (r) => context.showSuccess(r),
    );
  }

  deleteOrder(String orderId) async {
    final res = await _repo.deleteOrder(orderId);
    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show(r),
    );
  }
}
