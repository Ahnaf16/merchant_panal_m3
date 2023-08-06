import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/point_of_sale/ctrl/pos_ctrl.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EditProductDialog extends ConsumerWidget {
  const EditProductDialog({
    super.key,
    required this.product,
    required this.orderId,
  });

  final CartModel product;
  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pos = ref.watch(posCtrlProvider(orderId));
    final posCtrl = ref.read(posCtrlProvider(orderId).notifier);

    final isPhone = product.category == Categories.smartPhone.title ||
        product.category == Categories.preOwned.title;

    return AlertDialog(
      title: const Text('Edit Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: posCtrl.productNameCtrl,
            decoration: const InputDecoration(labelText: 'Product name'),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: posCtrl.productPriceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(labelText: 'Product Price'),
          ),
          const SizedBox(height: 15),
          if (isPhone)
            TextField(
              controller: posCtrl.iMEICtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'IMEI',
                suffixIcon: IconButton(
                  onPressed: () => posCtrl.scanBarCode(),
                  icon: Icon(MdiIcons.barcodeScan),
                ),
              ),
            ),
          if (isPhone) const SizedBox(height: 15),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  posCtrl.updateQuantity(product, false);
                },
                icon: const Icon(Icons.remove_rounded),
              ),
              Chip(
                label: Text(
                  pos.products
                      .where((element) => element.id == product.id)
                      .first
                      .quantity
                      .toString(),
                ),
              ),
              IconButton(
                onPressed: () => posCtrl.updateQuantity(product, true),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton.outlined(
          onPressed: () => context.pop,
          icon: const Icon(Icons.close_rounded),
        ),
        OutlinedButton(
          onPressed: () {
            posCtrl.submitEditedProduct(product);
            context.pop;
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
