import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/employee/provider/employee_provider.dart';
import 'package:merchant_m3/feature/products/ctrl/product_add_edit_ctrl.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:merchant_m3/routes/route_names.dart';
import 'package:merchant_m3/widget/widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productEditCtrl = ref.read(productsEditCtrlProvider(null).notifier);
    final employee = ref.watch(permissionProvider);

    final canUpdate = EPermissions.productUpdate.canDo(employee);
    final canDelete = EPermissions.productDelete.canDo(employee);

    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.all(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => context.pushTo(RoutesName.productsDetails(product.id)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: KCachedImg(
                    url: product.imgUrls.first,
                    padding: const EdgeInsets.all(20).copyWith(bottom: 10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.showUntil(25),
                        style: context.textTheme.titleSmall,
                      ),
                      Text(
                        product.variant,
                        style: context.textTheme.bodySmall,
                      ),
                      product.pricingWidget,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!product.isEnabled)
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    backgroundColor: context.colorTheme.error.withOpacity(.9),
                    foregroundColor: context.colorTheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: canUpdate
                      ? () => productEditCtrl.toggleEnabledAndUpdate(product)
                      : Toaster.show('NO ACCESS !!'),
                  icon: const Icon(Icons.visibility_off_outlined),
                  label: const Text('Disabled'),
                ),
              ),
            ),
          ),
        Positioned(
          right: 10,
          bottom: 10,
          child: PopupMenuButton(
            position: PopupMenuPosition.over,
            icon: const Icon(Icons.more_horiz_rounded),
            itemBuilder: (context) => [
              PopupMenuTile(
                icon: Icons.visibility_rounded,
                child: const Text('View'),
                onTap: () =>
                    context.pushTo(RoutesName.productsDetails(product.id)),
              ),
              PopupMenuTile(
                icon: Icons.edit_rounded,
                child: const Text('Edit'),
                onTap: () =>
                    context.pushTo(RoutesName.editProducts(product.id)),
              ),
              if (canUpdate)
                PopupMenuTile(
                  icon: Icons.store_rounded,
                  child: const Text('Update Stock'),
                  onTap: () => productEditCtrl.toggleStockAndUpdate(product),
                ),
              if (canDelete)
                PopupMenuTile(
                  icon: Icons.delete_rounded,
                  child: const Text('Delete'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete ?'),
                      content: const Text('Are you sure ??'),
                      actions: [
                        IconButton.outlined(
                          onPressed: () => context.pop,
                          icon: const Icon(Icons.close_rounded),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              productEditCtrl.deleteProduct(product),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!product.inStock)
          Positioned(
            right: 10,
            child: IconButton.filledTonal(
              onPressed: canUpdate
                  ? () => productEditCtrl.toggleStockAndUpdate(product)
                  : () => EPermissions.showToast(),
              icon: Icon(MdiIcons.storeRemove),
            ),
          ),
      ],
    );
  }
}
