import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gngm/core/core.dart';
import 'package:gngm/feature/employee/provider/employee_provider.dart';
import 'package:gngm/feature/flash/ctrl/flash_ctrl.dart';
import 'package:gngm/feature/flash/view/local/set_flash_price_dialog.dart';
import 'package:gngm/feature/products/view/local/product_search_sheet.dart';
import 'package:gngm/models/models.dart';
import 'package:gngm/widget/widget.dart';

class FlashView extends ConsumerWidget {
  const FlashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashState = ref.watch(flashSaleCtrlProvider(null));
    final flashCtrl = ref.read(flashSaleCtrlProvider(null).notifier);
    final employee = ref.watch(permissionProvider);

    final canUpdate = EPermissions.flashAdd.canDo(employee);
    final canDelete = EPermissions.flashDelete.canDo(employee);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flash Sale'),
        actions: [
          if (canUpdate)
            FilledButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => ProductSearchBottomSheet(
                    onTrailingTap: (product) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            SetFlashPriceDialog(product: product),
                      );
                    },
                  ),
                );
              },
              label: const Text('Add Flash'),
              icon: const Icon(Icons.add_rounded),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: flashState.flashList.when(
        error: ErrorView.errorMathod,
        loading: Loader.loading,
        data: (flashes) => Padding(
          padding: const EdgeInsets.all(20),
          child: AdaptiveBody(
            child: ReorderableListView.builder(
              itemCount: flashes.length,
              onReorder: (oldIndex, newIndex) {
                if (canUpdate) {
                  if (oldIndex < newIndex) newIndex--;

                  flashCtrl.updatePriority(
                    flashes[oldIndex],
                    flashes[newIndex],
                  );
                }
              },
              footer: Card(
                child: ListTile(
                  leading: const Icon(Icons.help_rounded, size: 20),
                  titleTextStyle: context.textTheme.bodyMedium,
                  title: const Text(
                      'Press and Hold to Reorder Flash Sale Products'),
                ),
              ),
              itemBuilder: (BuildContext context, int index) {
                final flash = flashes[index];
                return Card(
                  key: ValueKey(flash.id),
                  child: ListTile(
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        if (canUpdate)
                          PopupMenuItem(
                            child: const Text('Edit'),
                            onTap: () {
                              Future.delayed(
                                Duration.zero,
                                () => showDialog(
                                  context: context,
                                  builder: (context) => SetFlashPriceDialog(
                                    editingFlash: flash,
                                  ),
                                ),
                              );
                            },
                          ),
                        if (canDelete)
                          PopupMenuItem(
                            child: const Text('Delete'),
                            onTap: () => Future.delayed(
                              Duration.zero,
                              () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete ?'),
                                  content: const Text('Are You Sure !!'),
                                  actions: [
                                    IconButton.outlined(
                                      onPressed: () => context.pop,
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                                    OutlinedButton(
                                      onPressed: () =>
                                          flashCtrl.deleteFlash(flash),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    leading: KCachedImg(
                      url: flash.image,
                      height: 40,
                      width: 40,
                    ),
                    title: Text(flash.name.showUntil(25)),
                    subtitle: Text(
                      flash.price.toCurrency(),
                    ).withDiscount(flash.flashPrice, true),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
