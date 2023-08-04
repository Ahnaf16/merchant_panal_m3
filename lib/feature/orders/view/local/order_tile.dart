import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/employee/provider/employee_provider.dart';
import 'package:gngm/feature/orders/ctrl/order_ctrl.dart';
import 'package:gngm/feature/orders/view/local/update_status_dialog.dart';
import 'package:gngm/models/models.dart';
import 'package:gngm/routes/route_names.dart';

class OrderTile extends ConsumerWidget {
  const OrderTile({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderCtrl = ref.watch(orderCtrlProvider(order).notifier);
    final employee = ref.watch(permissionProvider);

    final canUpdate = EPermissions.orderUpdate.canDo(employee);
    Offset offset = Offset.zero;

    void getPosition(TapDownDetails detail) {
      offset = detail.globalPosition;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.pushTo(RoutesName.ordersDetails(order.docID)),
      onTapDown: getPosition,
      onLongPress: () => longTap(context, orderCtrl, offset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${order.orderDate.formatDate('yyyy')}\n',
                    style: context.textTheme.bodySmall,
                  ),
                  TextSpan(
                    text: '${order.orderDate.formatDate('dd')}\n',
                    style: context.textTheme.titleMedium,
                  ),
                  TextSpan(
                    text: order.orderDate.formatDate('MMM'),
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            title: Row(
              children: [
                if (order.isFromPOS)
                  const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(Icons.point_of_sale_rounded, size: 15),
                  ),
                Text(order.invoice),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.address.name,
                  style: context.textTheme.bodyLarge,
                ),
                Text(
                  order.address.billingNumber,
                  style: context.textTheme.bodyLarge,
                ),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'BDT ',
                        style: context.textTheme.bodySmall,
                      ),
                      TextSpan(
                        text: order.total.numberFormate(),
                        style: context.textTheme.titleLarge,
                      ),
                      TextSpan(
                        text: ' (${order.products.length})',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (order.voucher > 0)
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.card_giftcard_rounded),
                      ),
                    if (order.gCoinUsed > 0)
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.paid_rounded),
                      ),
                    if (order.goProtectType != null)
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.shield_rounded),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InputChip(
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
                const SizedBox(width: 10),
                Chip(
                  label: Text(order.orderPaymentStatus),
                  padding: const EdgeInsets.all(0),
                ),
                const SizedBox(width: 10),
                Chip(
                  avatar:
                      order.paymentMethod.logo(context.colorTheme.onBackground),
                  label: Text(order.paymentMethod.title),
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void longTap(
      BuildContext context, OrderCtrlNotifier orderCtrl, Offset offset) {
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    RelativeRect relRectSize() =>
        RelativeRect.fromSize(offset & const Size(50, 50), overlay.size);
    showMenu<String>(
      context: context,
      position: relRectSize(),
      items: [
        PopupMenuItem(
          onTap: () => URLHelper.call(order.address.billingNumber),
          child: const Row(
            children: [
              Icon(Icons.phone_rounded),
              SizedBox(width: 10),
              Text('Call'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => ClipBoardAPI.copy(order.invoice),
          child: const Row(
            children: [
              Icon(Icons.copy_rounded),
              SizedBox(width: 10),
              Text('Copy invoice'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => orderCtrl.downloadInvoice(context),
          child: const Row(
            children: [
              Icon(Icons.download_rounded),
              SizedBox(width: 10),
              Text('Download Invoice'),
            ],
          ),
        ),
      ],
    );
  }
}
