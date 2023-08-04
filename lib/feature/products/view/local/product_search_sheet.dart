import 'package:gngm/feature/products/ctrl/products_list_ctrl.dart';
import 'package:gngm/models/models.dart';
import 'package:gngm/routes/route_names.dart';
import 'package:gngm/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gngm/core/core.dart';

class ProductSearchBottomSheet extends ConsumerWidget {
  const ProductSearchBottomSheet({
    super.key,
    this.trailingIcon,
    this.onTrailingTap,
    this.onTap,
  });

  final IconData? trailingIcon;
  final Function(ProductModel product)? onTrailingTap;
  final Function(String id)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsData = ref.watch(productsListCtrlProvider);
    final productCtrl = ref.read(productsListCtrlProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KDivider(),
              TextField(
                controller: productCtrl.searchCtrl,
                focusNode: productCtrl.searchFocus,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => productCtrl.search(),
                decoration: InputDecoration(
                  labelText: 'Search Product',
                  suffixIcon: IconButton(
                    onPressed: () => productCtrl.search(),
                    icon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              productsData.when(
                loading: Loader.loading,
                error: ErrorView.errorMathod,
                data: (products) {
                  return ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      final product = products[index];
                      return ListTile(
                        onTap: () {
                          if (onTap != null) {
                            onTap!(product.id);
                          } else {
                            context
                                .pushTo(RoutesName.productsDetails(product.id));
                          }
                          context.pop;
                        },
                        leading: KCachedImg(
                          url: product.imgUrls.first,
                          width: 40,
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            onTrailingTap == null
                                ? () {}
                                : onTrailingTap!(product);
                          },
                          icon: Icon(
                              trailingIcon ?? Icons.arrow_forward_ios_rounded),
                        ),
                        title: Text(product.name.showUntil(20)),
                        subtitle: product.pricingWidget,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
