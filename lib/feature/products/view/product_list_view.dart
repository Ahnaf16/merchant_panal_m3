import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/products/ctrl/products_list_ctrl.dart';
import 'package:gngm/feature/products/view/local/product_card.dart';
import 'package:gngm/feature/products/view/product_search.dart';
import 'package:gngm/widget/widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductListView extends ConsumerWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsData = ref.watch(productsListCtrlProvider);
    final productCtrl = ref.read(productsListCtrlProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton.filledTonal(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ProductSearchDialog(),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: productsData.when(
        error: ErrorView.errorMathod,
        loading: Loader.loading,
        data: (products) => SmartRefresher(
          physics: const ScrollPhysics(),
          controller: productCtrl.refreshCtrl,
          enablePullUp: true,
          onRefresh: () => productCtrl.reload(),
          onLoading: () => productCtrl.loadMore(products.last),
          footer: kIsWeb
              ? SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: IconButton.outlined(
                      onPressed: () => productCtrl.loadMore(products.last),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      tooltip: 'Load more',
                    ).adapt(context),
                  ),
                )
              : const ClassicFooter(),
          child: MasonryGridView.builder(
            physics: const ScrollPhysics(),
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.kCrossAxisCount,
            ),
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product);
            },
          ),
        ),
      ),
    );
  }
}
