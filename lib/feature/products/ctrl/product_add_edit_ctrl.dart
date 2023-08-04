// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/auth/provider/auth_provider.dart';
import 'package:gngm/feature/products/repo/products_repo.dart';
import 'package:gngm/feature/products/view/product_details_view.dart';
import 'package:gngm/models/models.dart';
import 'package:nanoid/nanoid.dart';

final productImageStateProvider =
    StateProvider.autoDispose<List<PlatformFile>>((ref) {
  return [];
});

final productsEditCtrlProvider = StateNotifierProvider.autoDispose
    .family<ProductsEditCtrlNotifier, ProductModel, String?>((ref, updatingId) {
  return ProductsEditCtrlNotifier(ref, updatingId).._init();
});

class ProductsEditCtrlNotifier extends StateNotifier<ProductModel> {
  ProductsEditCtrlNotifier(this._ref, this.updatingId)
      : super(ProductModel.empty);

  final Ref _ref;
  final String? updatingId;
  ProductsRepo get _repo => _ref.read(productsRepoProvider);

  final nameCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final discCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final discountCtrl = TextEditingController();
  final specCtrl = TextEditingController();

  _init() async {
    if (updatingId != null) {
      final fire = FirebaseFirestore.instance;
      final doc =
          await fire.collection(FirePath.products).doc(updatingId).get();
      final updateProduct = ProductModel.fromDoc(doc);
      state = updateProduct;
      nameCtrl.text = updateProduct.name;
      brandCtrl.text = updateProduct.brand;
      discCtrl.text = updateProduct.description;
      priceCtrl.text = updateProduct.price.toCurrency();
      discountCtrl.text = updateProduct.discountPrice.toCurrency();
    } else {
      state = ProductModel.empty;
      nameCtrl.clear();
      brandCtrl.clear();
      discCtrl.clear();
      priceCtrl.clear();
      discountCtrl.clear();
      specCtrl.clear();
    }
  }

  reload(String? id) async {
    await _init();
    _ref.read(productImageStateProvider.notifier).update((state) => []);
  }

  applyFields() {
    setID();
    state = state.copyWith(
      name: nameCtrl.text.trim(),
      brand: brandCtrl.text.trim(),
      description: discCtrl.text.trim(),
      price: priceCtrl.text.asInt,
      discountPrice: discountCtrl.text.asInt,
      employeeName: getUser?.displayName ?? 'noName',
    );
  }

  setID() {
    if (state.id.isEmpty) {
      state = state.copyWith(id: nanoid().replaceAll('/', '_'));
    }
  }

  toggleStock() => state = state.copyWith(inStock: !state.inStock);
  toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);
  toggleDiscount() => state = state.copyWith(haveDiscount: !state.haveDiscount);

  updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  selectImage() async {
    final picker = _ref.watch(filePickerProvider);
    final files = await picker.pickMultipleImage();
    files.fold(
      (l) => Toaster.showFailure(l),
      (r) => _ref
          .read(productImageStateProvider.notifier)
          .update((state) => [...state, ...r]),
    );
  }

  onImageDrop(List<PlatformFile> files) async => _ref
      .read(productImageStateProvider.notifier)
      .update((state) => [...state, ...files]);

  removeImage(int index, bool isFile) {
    if (isFile) {
      _ref.read(productImageStateProvider.notifier).update(
          (state) => [...state.sublist(0, index), ...state.sublist(index + 1)]);
    } else {
      final updateList = [
        ...state.imgUrls.sublist(0, index),
        ...state.imgUrls.sublist(index + 1)
      ];
      state = state.copyWith(imgUrls: updateList);
    }
  }

  addSpec() {
    final index = specCtrl.text.indexOf('~');
    final key = specCtrl.text.substring(0, index);
    final value = specCtrl.text.substring(index + 1);
    if (value.isEmpty) {
      Toaster.show('Add something');
      return 0;
    }

    state =
        state.copyWith(specifications: {...state.specifications, key: value});
  }

  addSpecificSpec(String key, String value) {
    specCtrl.text = '$key~$value';
    addSpec();
  }

  removeSpec(String key) {
    final spec = state.specifications;
    spec.remove(key);

    state = state.copyWith(specifications: {...spec});
  }

  markAsDuplicate() {
    state = state.copyWith(
      isDuplicate: true,
      date: DateTime.now(),
    );
  }

  showPreview(BuildContext context, bool isUpdate) async {
    applyFields();

    await showDialog(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(),
        floatingActionButton: isValid.$1
            ? FloatingActionButton(
                onPressed: () async {
                  await addOrUpdateProduct(context, isUpdate);
                },
                child: const Icon(Icons.done_rounded),
              )
            : null,
        body: ProductDetailsBody(
          product: state,
          imgFiles: _ref.read(productImageStateProvider),
        ),
      ),
    );
  }

  addOrUpdateProduct(BuildContext context, bool isUpdate) async {
    final uploader = _ref.watch(fileUploaderProvider);
    final imgFiles = _ref.read(productImageStateProvider);

    context.showLoader();
    applyFields();

    if (imgFiles.isEmpty && state.imgUrls.isEmpty) {
      context.showError('No image is provided');
      return 0;
    }
    if (!isValid.$1) {
      context.showError(isValid.$2);
      return 0;
    }

    if (imgFiles.isNotEmpty) {
      final imgUrls = await uploader.uploadMultiImage(
        fileName: state.name,
        storagePath: StoragePath.product,
        imgPaths: imgFiles,
        startIndex: state.imgUrls.length,
      );
      imgUrls.fold(
        (l) => Toaster.showFailure(l),
        (r) {
          _ref.read(productImageStateProvider.notifier).update((state) => []);
          state = state.copyWith(imgUrls: [...state.imgUrls, ...r]);
        },
      );
    }
    if (state.imgUrls.isEmpty) {
      context.showError('No image is provided');
      return 0;
    }
    if (isUpdate) {
      final res = await _repo.updateProduct(state);

      res.fold(
        (l) => context.showError(l.message),
        (r) => context.showSuccess('Product Updated'),
      );
    } else {
      state = state.copyWith(date: DateTime.now());
      final res = await _repo.addProduct(state);

      res.fold(
        (l) => context.showError(l.message),
        (r) => context.showSuccess('Product Added'),
      );
    }
  }

  createDuplicate(BuildContext context) async {
    context.showLoader();
    applyFields();
    state = state.copyWith(
      isDuplicate: true,
      date: DateTime.now(),
      id: nanoid().replaceAll('/', '_'),
    );

    final res = await _repo.addProduct(state);

    res.fold(
      (l) => context.showError(l.message),
      (r) => context.showSuccess('Product duplicated'),
    );
  }

  deleteProduct(ProductModel product) async {
    final uploader = _ref.watch(fileUploaderProvider);
    final res = await _repo.deleteProduct(product.id);

    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show('Product Deleted'),
    );

    if (!product.isDuplicate) {
      final upLoaderRes = await uploader.deleteImage(
        storagePath: StoragePath.product,
        fileName: product.name,
      );

      upLoaderRes.fold(
        (l) => Toaster.showFailure(l),
        (r) => Toaster.show('Product Image Deleted'),
      );
    }
  }

  toggleStockAndUpdate(ProductModel product) async {
    final updated = product.copyWith(inStock: !product.inStock);
    final res = await _repo.updateProduct(updated);
    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show('Updated Product Stock'),
    );
  }

  toggleEnabledAndUpdate(ProductModel product) async {
    final updated = product.copyWith(isEnabled: !product.isEnabled);
    final res = await _repo.updateProduct(updated);
    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show(
        'Product ' '${state.isEnabled ? 'Enabled' : 'Disabled'}',
      ),
    );
  }

  (bool, String) get isValid {
    if (state.name.isEmpty) {
      return (false, 'No Name is provided');
    }
    if (state.brand.isEmpty) {
      return (false, 'No Brand is provided');
    }
    if (state.description.isEmpty) {
      return (false, 'No Description is provided');
    }
    if (state.price == 0) {
      return (false, 'Price can not be 0');
    }
    if (state.haveDiscount && state.discountPrice == 0) {
      return (false, 'Discount Price can not be 0');
    }
    if (state.category.isEmpty) {
      return (false, 'No Category is provided');
    }

    return (true, 'Adding...');
  }
}
