import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/extensions/context_extension.dart';
import 'package:merchant_m3/feature/products/ctrl/products_list_ctrl.dart';

class ProductSearchDialog extends ConsumerWidget {
  const ProductSearchDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productCtrl = ref.read(productsListCtrlProvider.notifier);

    return WillPopScope(
      onWillPop: () {
        return Future(() => true);
      },
      child: AlertDialog(
        alignment: Alignment.topCenter + const Alignment(0, 0.3),
        title: const Text('Search'),
        actions: [
          IconButton.outlined(
            onPressed: () => context.pop,
            icon: const Icon(Icons.close_rounded),
          ),
          FilledButton.icon(
            onPressed: () async {
              await productCtrl.search();
              context.pop;
            },
            icon: const Icon(Icons.search_rounded),
            label: const Text('Search'),
          ),
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              focusNode: productCtrl.searchFocus..requestFocus(),
              controller: productCtrl.searchCtrl,
              textInputAction: TextInputAction.go,
              onSubmitted: (value) async {
                await productCtrl.search();
                context.pop;
              },
              decoration: InputDecoration(
                filled: true,
                isDense: true,
                suffixIcon: IconButton(
                  onPressed: () => productCtrl.searchCtrl.clear(),
                  icon: const Icon(Icons.clear_rounded),
                ),
                hintText: 'Search ...',
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
