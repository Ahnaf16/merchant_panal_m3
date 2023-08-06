import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/products/repo/products_repo.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final productsListCtrlProvider = StateNotifierProvider<ProductsListCtrlNotifier,
    AsyncValue<List<ProductModel>>>((ref) {
  return ProductsListCtrlNotifier(ref).._init();
});

class ProductsListCtrlNotifier
    extends StateNotifier<AsyncValue<List<ProductModel>>> {
  ProductsListCtrlNotifier(this._ref) : super(const AsyncValue.loading());
  final Ref _ref;
  ProductsRepo get _repo => _ref.read(productsRepoProvider);

  final refreshCtrl = RefreshController();
  final searchCtrl = TextEditingController();
  final searchFocus = FocusNode();

  @override
  void dispose() {
    refreshCtrl.dispose();
    searchCtrl.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  _init() async {
    final res = await _repo.fetchProducts();
    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => _putData(r),
    );
  }

  reload() async {
    await _init();
    refreshCtrl.refreshCompleted();
  }

  loadMore(ProductModel last) async {
    if (searchCtrl.text.isNotEmpty) {
      return 0;
    }

    final List<ProductModel> stateItem = state.maybeWhen(
      data: (data) => data,
      orElse: () => List.empty(),
    );

    final res = await _repo.fetchNextBatch(last);

    res.fold(
      (l) => Toaster.showFailure(l),
      (r) async {
        await for (final product in r) {
          state = AsyncValue.data(stateItem + product);
          refreshCtrl.loadComplete();
        }
      },
    );
  }

  search() async {
    final searchProducts = await _repo.search(searchCtrl.text);
    searchProducts.fold(
      (l) => Toaster.showFailure(l),
      (r) => _putData(r),
    );
    searchFocus.unfocus();
  }

  clear() async {
    await _init();
    searchCtrl.clear();
    searchFocus.unfocus();
  }

  _putData(Stream<List<ProductModel>> productStream) async {
    await for (final items in productStream) {
      state = AsyncValue.data(items);
    }
  }
}
