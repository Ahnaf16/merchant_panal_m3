import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/auth/provider/auth_provider.dart';
import 'package:merchant_m3/models/models.dart';

import 'package:gsheets/gsheets.dart';

final gSheetCtrlProvider =
    StateNotifierProvider<GoogleSheetCtrlNotifier, bool>((ref) {
  return GoogleSheetCtrlNotifier();
});

class GoogleSheetCtrlNotifier extends StateNotifier<bool> {
  GoogleSheetCtrlNotifier() : super(false);

  final _fire = FirebaseFirestore.instance;

  Future<GSheetCredModel> _getSheetCred() async {
    final snap = await _fire
        .collection(FirePath.appConfig)
        .doc(FirePath.gsheetCred)
        .get();

    return GSheetCredModel.fromDoc(snap);
  }

  FutureEither<String> addOrderToGSheet(OrderModel order) async {
    final sheetCred = await _getSheetCred();

    try {
      Toaster.show('preparing Google Sheet');
      final sheet = GSheets(sheetCred.key);

      final gsheet = await sheet.spreadsheet(sheetCred.id);
      final gsheetBackUp = await sheet.spreadsheet(sheetCred.backupId);

      final isPhone = order.containsPhone();
      final isDhaka = order.address.division == 'Dhaka';

      final worksheet = gsheet.worksheetByTitle(isPhone ? 'Sheet2' : 'Sheet1');
      final worksheetBackUp =
          gsheetBackUp.worksheetByTitle(isPhone ? 'Sheet2' : 'Sheet1');

      final goProtect = order.goProtectAsCart();

      final carts = [...order.products, if (goProtect != null) goProtect];

      final rowData = [
        order.invoice,
        order.address.name,
        (order.address.fullAddress),
        order.address.billingNumber,
        carts.map((item) => '${item.name} (${item.variant})').join(','),
        carts.map((item) => item.quantity).join(','),
        order.total,
        order.total == order.paidAmount
            ? 'Full Paid'
            : (order.paidAmount == 0
                ? 'Full Condition'
                : '${order.total - order.paidAmount} Condition'),
        !isPhone
            ? 'E-Courier'
            : isDhaka && isPhone
                ? 'E-Courier'
                : 'Sundarban',
        '${order.paymentMethod.title} : ${order.paidAmount}',
        DateTime.now().formatDate('dd/MM/yyy hh:mm:ss'),
        getUser?.displayName,
      ];
      Toaster.show('Adding to Google Sheet');
      await worksheet?.values.appendRow(rowData);
      Toaster.show('Adding to Backup Google Sheet');
      await worksheetBackUp!.values.appendRow(rowData);
      return right('Google Sheet Added');
    } on Exception catch (err) {
      return left(Failure.fromException(err));
    }
  }
}
