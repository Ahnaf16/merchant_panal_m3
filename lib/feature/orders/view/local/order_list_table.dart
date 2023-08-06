import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/employee/provider/employee_provider.dart';
import 'package:merchant_m3/feature/orders/ctrl/order_list_ctrl.dart';
import 'package:merchant_m3/feature/orders/view/local/update_status_dialog.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:merchant_m3/routes/route_names.dart';

import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderListTable extends ConsumerWidget {
  const OrderListTable({super.key, required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderCtrl = ref.read(orderListCtrlProvider.notifier);
    final employee = ref.watch(permissionProvider);
    final canUpdate = EPermissions.orderUpdate.canDo(employee);

    const columnTitle = [
      'No',
      'Invoice',
      'Name',
      'Contact',
      'Total',
      'Paid with',
      'Status',
      'Date',
    ];

    _SFdataSource orderDataSource() =>
        _SFdataSource(orders, columnTitle, context, canUpdate);

    return SelectionArea(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SfDataGrid(
            verticalScrollPhysics: const ScrollPhysics(),
            onCellTap: (details) {
              final index = details.rowColumnIndex.rowIndex - 1;
              context.pushTo(RoutesName.ordersDetails(orders[index].docID));
            },
            shrinkWrapRows: true,
            source: orderDataSource(),
            gridLinesVisibility: GridLinesVisibility.both,
            headerGridLinesVisibility: GridLinesVisibility.both,
            headerRowHeight: 35,
            footerHeight: 60,
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: IconButton.outlined(
                    onPressed: () => orderCtrl.refreshCtrl.requestLoading(),
                    icon: const Icon(
                      Icons.arrow_forward,
                    ),
                    tooltip: 'Load more',
                  ),
                ),
              ],
            ),
            columns: [
              ...columnTitle.map(
                (title) => GridColumn(
                  columnWidthMode: title == 'No'
                      ? ColumnWidthMode.fitByCellValue
                      : ColumnWidthMode.fill,
                  columnName: title,
                  label: Center(
                    child: Text(title),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SFdataSource extends DataGridSource {
  _SFdataSource(
      List<OrderModel> orders, this.columnTitle, this.context, this.canUpdate) {
    _init(orders);
  }

  final bool canUpdate;
  List<String> columnTitle;
  final BuildContext context;
  late List<DataGridRow> dataRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) => cell.value).toList(),
    );
  }

  @override
  List<DataGridRow> get rows => dataRows;

  Widget _textWidget(String text, [bool canCopy = true]) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: text,
          recognizer: TapGestureRecognizer()
            ..onTap = canCopy ? () => ClipBoardAPI.copy(text) : null,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  _init(List<OrderModel> orders) {
    dataRows = List.generate(
      orders.length,
      (index) {
        final order = orders[index];

        final List<Widget> dataList = [
          SizedBox(
            width: 50,
            child: Center(child: Text('${index + 1}')),
          ),
          //--------------------------------------------------------------------
          _textWidget(order.invoice),

          //--------------------------------------------------------------------
          _textWidget(order.address.name),

          //--------------------------------------------------------------------
          _textWidget(order.address.billingNumber),

          //--------------------------------------------------------------------
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _textWidget(order.total.toCurrency(), false),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (order.voucher > 0)
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.card_giftcard_rounded, size: 18),
                      ),
                    if (order.gCoinUsed > 0)
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.paid_rounded, size: 18),
                      ),
                    if (order.goProtectType != null)
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.shield_rounded, size: 18),
                      ),
                  ],
                ),
              ),
            ],
          ),

          //--------------------------------------------------------------------
          CircleAvatar(
            backgroundColor: Colors.transparent,
            child: order.paymentMethod.logo(context.colorTheme.onBackground),
          ),

          //--------------------------------------------------------------------
          Center(
            child: InputChip(
              side: BorderSide(color: order.status.color),
              label: Text(order.status.title),
              padding: const EdgeInsets.all(0),
              onPressed: () {
                if (canUpdate) {
                  showDialog(
                    context: context,
                    builder: (context) => UpdateStatusDialog(order: order),
                  );
                }
              },
            ),
          ),

          //--------------------------------------------------------------------
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                order.orderDate.formatDate('hh:MM a\ndd-MM-yyyy'),
              ),
            ),
          ),
        ];

        return DataGridRow(
          cells: [
            ...List.generate(
              columnTitle.length,
              (columnIndex) {
                return DataGridCell(
                  columnName: columnIndex.toString(),
                  value: dataList[columnIndex],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
