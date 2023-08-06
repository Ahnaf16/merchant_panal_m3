import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';

import 'package:merchant_m3/feature/point_of_sale/ctrl/pos_ctrl.dart';
import 'package:merchant_m3/feature/products/view/local/product_search_sheet.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:merchant_m3/widget/widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class POSView extends ConsumerWidget {
  const POSView(this.orderId, {super.key});
  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.watch(posCtrlProvider(orderId));
    final posCtrl = ref.read(posCtrlProvider(orderId).notifier);
    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Point of Sale'),
          actions: [
            IconButton.outlined(
              onPressed: () => posCtrl.refresh(),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reload',
            ).adapt(context),
            if (kIsWeb) const SizedBox(width: 10),
            IconButton.filledTonal(
              onPressed: () {
                context.removeFocus;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Place Order ?'),
                    content: const Text('Add new order from Point of Sale ?'),
                    actions: [
                      IconButton.outlined(
                        onPressed: () => context.pop,
                        icon: const Icon(Icons.close_rounded),
                      ),
                      IconButton.filled(
                        onPressed: () => posCtrl.submitPOS(context, true),
                        icon: Icon(MdiIcons.googleSpreadsheet),
                        tooltip: 'Add to G-sheet after placing order',
                      ),
                      FilledButton.icon(
                        onPressed: () => posCtrl.submitPOS(context, false),
                        icon: const Icon(Icons.done_all_rounded),
                        label: const Text('Place Order'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.done_rounded),
              tooltip: 'Submit',
            ).adapt(context),
            const SizedBox(width: 10),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AdaptiveBody(
              child: Column(
                children: [
                  InformativeCard(
                    header: 'Products',
                    actions: [
                      OutlinedButton.icon(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          builder: (context) => ProductSearchBottomSheet(
                            onTrailingTap: (product) =>
                                posCtrl.addProductToOrder(product),
                          ),
                        ),
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Search Product'),
                      ),
                    ],
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: pos.products.length,
                        itemBuilder: (BuildContext context, int index) {
                          final product = pos.products[index];
                          return ListTile(
                            isThreeLine: true,
                            leading: KCachedImg(url: product.img),
                            title: Text(product.name.showUntil(20)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${product.price.toCurrency()} x ${product.quantity}'
                                  '  : (${product.total.toCurrency()})',
                                ),
                                const SizedBox(height: 5),
                                if (product.imei.isNotEmpty)
                                  Text('IMEI:${product.imei}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton.outlined(
                                  onPressed: () =>
                                      posCtrl.showEditProductDialog(
                                    context,
                                    product,
                                  ),
                                  icon: const Icon(Icons.edit_rounded),
                                ),
                                IconButton.outlined(
                                  onPressed: () =>
                                      posCtrl.removeProductToOrder(index),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  InformativeCard(
                    header: 'Go Protect',
                    actions: [
                      Switch(
                        value: pos.goProtectType != null,
                        onChanged: !posCtrl.isGoProtectUsable
                            ? null
                            : (value) {
                                if (value) {
                                  posCtrl.applyGoProtect(
                                      GoProtectType.fivePercent);
                                } else {
                                  posCtrl.applyGoProtect(null);
                                }
                              },
                      ),
                    ],
                    children: [
                      if (posCtrl.goProtectError != null)
                        Text(
                          posCtrl.goProtectError!,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: context.colorTheme.error,
                          ),
                        ),
                      if (posCtrl.isGoProtectUsable)
                        Row(
                          children: [
                            ...GoProtectType.values.map(
                              (e) => Flexible(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: RadioListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    tileColor:
                                        context.colorTheme.surfaceVariant,
                                    title:
                                        Text('Go Protect (${e.percentage}%)'),
                                    value: e,
                                    groupValue: pos.goProtectType,
                                    onChanged: (value) {
                                      posCtrl.applyGoProtect(e);
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                    ],
                  ),
                  InformativeCard(
                    header: 'Customer Details',
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: posCtrl.customerNameCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                  labelText: 'Customer Name'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child: TextField(
                              controller: posCtrl.phoneNumberCtrl,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11),
                              ],
                              decoration: const InputDecoration(
                                  labelText: 'Phone Number'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: pos.address.division.isNotEmpty
                                  ? pos.address.division
                                  : null,
                              hint: const Text('Division'),
                              items: [
                                ...BDLocations.values.map(
                                  (e) => DropdownMenuItem(
                                    value: e.division,
                                    child: Text(e.division),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                posCtrl.selectDivision(value!);
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: pos.address.district.isNotEmpty
                                  ? pos.address.district
                                  : null,
                              hint: const Text('District'),
                              items: [
                                ...BDLocations.fromDivision(
                                        pos.address.division)
                                    .district
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e))),
                              ],
                              onChanged: (value) {
                                posCtrl.selectDistrict(value!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: posCtrl.addressCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                    ],
                  ),
                  InformativeCard(
                    header: 'Payment Details',
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: posCtrl.deliveryCtrl,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Delivery Charge',
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      posCtrl.applyDeliveryCharge(),
                                  icon:
                                      const Icon(Icons.cloud_download_outlined),
                                  tooltip: 'Fetch from Database',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child: TextField(
                              controller: posCtrl.paidAmountCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                  labelText: 'Advance payment'),
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
        ),
      ),
    );
  }
}
