import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:merchant_m3/feature/employee/provider/employee_provider.dart';
import 'package:merchant_m3/feature/orders/ctrl/order_ctrl.dart';
import 'package:merchant_m3/feature/orders/view/local/update_paid_amount_dialog.dart';
import 'package:merchant_m3/feature/orders/view/local/update_status_dialog.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/orders/providers/order_provider.dart';
import 'package:merchant_m3/routes/route_names.dart';
import 'package:merchant_m3/widget/widget.dart';

class OrderDetailsView extends ConsumerWidget {
  const OrderDetailsView(this.id, {super.key});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderData = ref.watch(orderDetailsProvider(id));
    final employee = ref.watch(permissionProvider);

    final canDelete = EPermissions.orderDelete.canDo(employee);
    final canUpdate = EPermissions.orderUpdate.canDo(employee);

    return orderData.when(
      error: ErrorView.errorMathod,
      loading: () => const Loader(),
      data: (order) {
        final orderCtrl = ref.watch(orderCtrlProvider(order).notifier);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Order Details'),
            actions: [
              if (canUpdate)
                IconButton.filledTonal(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Add To G-Sheet'),
                      content: const Text(
                          'Add Order to G-Sheet.\nThis might take some time.'),
                      actions: [
                        IconButton.outlined(
                          onPressed: () => context.pop,
                          icon: const Icon(Icons.close_rounded),
                        ),
                        FilledButton(
                          onPressed: () => orderCtrl.addToGoogleSheet(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                  icon: Icon(MdiIcons.googleSpreadsheet),
                  tooltip: 'Add to G-Sheet',
                ).adapt(context),
              if (!context.isSmall) const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () => orderCtrl.downloadInvoice(context),
                icon: const Icon(Icons.download_rounded),
                tooltip: 'Download',
              ).adapt(context),
              if (!context.isSmall) const SizedBox(width: 10),
              if (kIsWeb)
                IconButton.filledTonal(
                  onPressed: () => orderCtrl.openInvoice(context),
                  icon: const Icon(Icons.file_open_rounded),
                  tooltip: 'Open Invoice',
                ),
              if (!context.isSmall) const SizedBox(width: 10),
              if (EPermissions.orderToPOS.canDo(employee))
                IconButton.filledTonal(
                  onPressed: () => context
                      .pushTo(RoutesName.pos, query: {'id': order.docID}),
                  icon: const Icon(Icons.point_of_sale_rounded),
                  tooltip: 'Open in POS',
                ).adapt(context),
              if (!context.isSmall) const SizedBox(width: 10),
              if (canDelete)
                IconButton.outlined(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Order'),
                      content:
                          const Text('Are you sure?\nThis Can not be undone!'),
                      actions: [
                        IconButton.outlined(
                          onPressed: () => context.pop,
                          icon: const Icon(Icons.close_rounded),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colorTheme.error,
                            foregroundColor: context.colorTheme.onError,
                          ),
                          onPressed: () {
                            context.pop;
                            context.rPop();
                            orderCtrl.deleteOrder(order.docID);
                          },
                          icon: const Icon(Icons.delete_forever_rounded),
                          label: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.delete_rounded),
                  tooltip: 'Delete Order',
                ),
              const SizedBox(width: 10),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!context.isSmall)
                        Text('Invoice :', style: context.textTheme.titleLarge),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: context.textTheme.titleLarge,
                        ),
                        onPressed: () => ClipBoardAPI.copy(order.invoice),
                        onLongPress: () {
                          if (EPermissions.firestoreAccess.canDo(employee)) {
                            URLHelper.goTo(FireUrls.fireOrderUrl(order.docID));
                          } else {
                            EPermissions.showToast();
                          }
                        },
                        child: Text(order.invoice),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_month_rounded),
                      const SizedBox(width: 10),
                      Text(
                        context.isSmall
                            ? order.orderDate
                                .formatDate('EEE, LLL d. y,\nh:mm a')
                            : order.orderDate
                                .formatDate('h:mm a, EEE, LLL d. y'),
                        style: context.textTheme.titleMedium,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MasonryGridView.builder(
                    physics: const ScrollPhysics(),
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: order.products.length == 1
                          ? 1
                          : context.crossAxisCustom(1, 2, 2),
                    ),
                    shrinkWrap: true,
                    itemCount: order.products.length,
                    itemBuilder: (BuildContext context, int index) {
                      final product = order.products[index];
                      return _OrderedItemCard(product: product);
                    },
                  ),
                  const SizedBox(height: 10),
                  MasonryGridView(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 2,
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.crossAxisCustom(1, 2, 3),
                    ),
                    children: [
                      InformativeCard(
                        header: 'Payment Info',
                        actions: [
                          if (canUpdate)
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      UpdatePaidAmountDialog(order: order),
                                );
                              },
                              icon: const Icon(Icons.edit_rounded),
                            ),
                        ],
                        children: [
                          DualText(
                            left: 'Subtotal',
                            right: order.subTotal.toCurrency(),
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'Delivery Charge',
                            right: '+ ${order.deliveryCharge.toCurrency()}',
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            icon: Icons.card_giftcard_rounded,
                            left: 'Voucher',
                            right: '- ${order.voucher.toCurrency()}',
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            icon: Icons.paid_rounded,
                            left: 'G Coin',
                            right: '- ${order.gCoinUsed.toCurrency()}',
                          ),
                          if (order.isGoProtected) const SizedBox(height: 10),
                          if (order.isGoProtected)
                            DualText(
                              icon: Icons.shield_rounded,
                              left: 'Go Protect',
                              right: '+ ${order.goProtectPrice.toCurrency()}',
                            ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'Total',
                            right: order.total.toCurrency(),
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'Paid Amount',
                            right: order.paidAmount.toCurrency(),
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'Due',
                            right:
                                (order.total - order.paidAmount).toCurrency(),
                            warn: order.total > order.paidAmount,
                          ),
                        ],
                      ),
                      InformativeCard(
                        header: 'Customer Info',
                        actions: [
                          IconButton(
                            onPressed: () =>
                                URLHelper.call(order.address.billingNumber),
                            icon: const Icon(Icons.call_rounded),
                          ),
                          IconButton(
                            onPressed: () =>
                                URLHelper.massage(order.address.billingNumber),
                            icon: const Icon(Icons.messenger_rounded),
                          ),
                        ],
                        children: [
                          DualText(
                            left: 'Name',
                            right: order.address.name,
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'Phone',
                            right: order.address.billingNumber,
                          ),
                          if (order.user.email.isNotEmpty)
                            const SizedBox(height: 10),
                          if (order.user.email.isNotEmpty)
                            DualText(
                              left: 'Email',
                              right: order.user.email,
                              onTap: () => ClipBoardAPI.copy(order.user.uid),
                            ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'UID',
                            right: order.user.uid,
                            onTap: () => ClipBoardAPI.copy(order.user.uid),
                          ),
                        ],
                      ),
                      InformativeCard(
                        header: 'Order Info',
                        actions: [
                          if (canUpdate)
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      UpdateStatusDialog(order: order),
                                );
                              },
                              icon: const Icon(Icons.edit_rounded),
                            ),
                        ],
                        children: [
                          DualText(
                            left: 'Payment Method',
                            right: order.paymentMethod.title,
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'Order Status',
                            right: order.status.title,
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'Order Payment Status',
                            right: order.orderPaymentStatus,
                          ),
                        ],
                      ),
                      if (order.bkashData != null)
                        InformativeCard(
                          header: 'Bkash Info',
                          children: [
                            DualText(
                              left: 'Bkash Transaction Id',
                              right: order.bkashData!.trxId.ifEmpty(),
                              onTap: () => ClipBoardAPI.copy(
                                order.bkashData!.trxId,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DualText(
                              left: 'Is Partial',
                              right: order.bkashData!.isPartial ? 'Yes' : 'No',
                            ),
                            const SizedBox(height: 10),
                            DualText(
                              left: 'Payment Date',
                              right: order.bkashData!.paymentDate.formatDate(),
                            ),
                          ],
                        ),
                      InformativeCard(
                        header: 'Delivery Info',
                        children: [
                          DualText(
                            left: 'Division',
                            right: order.address.division,
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'District',
                            right: order.address.district,
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'Address',
                            right: order.address.address,
                          ),
                        ],
                      ),
                      InformativeCard(
                        header: 'Employee Info',
                        children: [
                          DualText(
                            left: 'Last Modified by',
                            right: order.lastModBy,
                          ),
                          const SizedBox(height: 10),
                          DualText(
                            left: 'Modified Date',
                            right: order.lastMod.formatDate(),
                          ),
                        ],
                      ),
                      InformativeCard(
                        header: 'Timelines',
                        children: [
                          ...order.timeLine.map(
                            (e) => ExpansionTile(
                              title: Text(e.status.title),
                              childrenPadding:
                                  const EdgeInsets.fromLTRB(20, 0, 20, 10),
                              children: [
                                Row(
                                  children: [
                                    Text(e.date.formatDate()),
                                    const Spacer(),
                                    Text(e.userName)
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(e.comment)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrderedItemCard extends StatelessWidget {
  const _OrderedItemCard({
    required this.product,
  });

  final CartModel product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.pushTo(RoutesName.productsDetails(product.id)),
        isThreeLine: true,
        leading: KCachedImg(
          width: 40,
          url: product.img,
          fit: BoxFit.contain,
        ),
        title: Text(product.name.showUntil(30)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.price.toCurrency()}  x  ${product.quantity}'),
            if (product.variant.isNotEmpty) Text(product.variant),
            if (product.imei.isNotEmpty)
              Text.rich(
                TextSpan(
                  text: 'IMEI : ${product.imei}',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => ClipBoardAPI.copy(product.imei),
                ),
              ),
          ],
        ),
        trailing: Text(product.total.toCurrency()),
        leadingAndTrailingTextStyle: context.textTheme.titleMedium,
      ),
    );
  }
}
