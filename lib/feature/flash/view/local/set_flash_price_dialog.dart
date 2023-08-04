import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gngm/core/core.dart';
import 'package:gngm/feature/flash/ctrl/flash_ctrl.dart';
import 'package:gngm/models/models.dart';
import 'package:gngm/widget/widget.dart';

class SetFlashPriceDialog extends ConsumerWidget {
  const SetFlashPriceDialog({
    super.key,
    this.product,
    this.editingFlash,
  });

  final ProductModel? product;
  final FlashModel? editingFlash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashCtrl = ref.read(flashSaleCtrlProvider(editingFlash).notifier);
    final isUpdating = editingFlash != null;
    return AlertDialog(
      title: isUpdating
          ? const Text('Update Flash Price')
          : const Text('Set Flash Price'),
      actions: [
        IconButton.outlined(
          onPressed: () => context.pop,
          icon: const Icon(Icons.close_rounded),
        ),
        OutlinedButton(
          onPressed: () => onSubmit(flashCtrl, context),
          child: isUpdating
              ? const Text('Update Flash Price')
              : const Text('Add to Flash'),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: flashCtrl.flashPriceCtrl,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (value) => onSubmit(flashCtrl, context),
            decoration: InputDecoration(
              labelText: 'Flash Price',
              suffixIcon: IconButton(
                onPressed: () => onSubmit(flashCtrl, context),
                icon: const Icon(Icons.done_rounded),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (product != null)
            Card(
              child: ListTile(
                leading: KCachedImg(
                  url: product!.imgUrls.first,
                  width: 40,
                ),
                title: Text(product!.name.showUntil(20)),
                subtitle: product!.pricingWidget,
              ),
            ),
          if (editingFlash != null)
            Stack(
              children: [
                Card(
                  child: ListTile(
                    leading: KCachedImg(
                      url: editingFlash!.image,
                      width: 40,
                    ),
                    title: Text(editingFlash!.name.showUntil(20)),
                    subtitle: Text(editingFlash!.price.toCurrency())
                        .withDiscount(editingFlash!.flashPrice, true),
                  ),
                ),
                const Icon(Icons.bolt_rounded),
              ],
            ),
        ],
      ),
    );
  }

  void onSubmit(FlashSaleCtrlNotifier flashCtrl, BuildContext context) {
    if (editingFlash != null) {
      flashCtrl.updateFlash(context, editingFlash);
    } else {
      flashCtrl.addFlashProduct(context, product);
    }
  }
}
