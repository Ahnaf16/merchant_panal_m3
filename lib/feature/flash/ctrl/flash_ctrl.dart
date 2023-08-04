// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gngm/core/core.dart';
import 'package:gngm/feature/flash/repo/flash_repo.dart';
import 'package:gngm/models/models.dart';

final flashSaleCtrlProvider = StateNotifierProvider.family<
    FlashSaleCtrlNotifier, FlashSaleState, FlashModel?>((ref, editingFlash) {
  return FlashSaleCtrlNotifier(ref).._init(editingFlash);
});

class FlashSaleCtrlNotifier extends StateNotifier<FlashSaleState> {
  FlashSaleCtrlNotifier(this._ref) : super(FlashSaleState.empty);

  final flashPriceCtrl = TextEditingController();

  final Ref _ref;

  reload() async {
    await _init();
  }

  updatePriority(FlashModel newFlash, FlashModel oldFlash) async {
    final res = await _repo.updatePriority(newFlash, oldFlash);
    res.fold((l) => Toaster.showFailure(l), (r) => Toaster.show(r));
  }

  deleteFlash(FlashModel flash) async {
    final res = await _repo.deleteFlash(flash.id);

    res.fold((l) => Toaster.showFailure(l), (r) => Toaster.show(r));
  }

  addFlashProduct(BuildContext context, ProductModel? product) async {
    if (flashPriceCtrl.text.isEmpty) {
      context.showError('Enter Flash Amount');
      return 0;
    }
    if (product == null) {
      context.showError('Error on product');
      return 0;
    }
    if (flashPriceCtrl.text.asInt >= product.price) {
      context.showError('Flash Amount Cant be same greater then product price');
      return 0;
    }
    FlashModel flash = FlashModel.fromProduct(product);
    flash = flash.copyWith(flashPrice: flashPriceCtrl.text.asInt);

    final res = await _repo.addFlash(flash);

    res.fold((l) => Toaster.showFailure(l), (r) => Toaster.show(r));

    context.pop;
    flashPriceCtrl.clear();
  }

  updateFlash(BuildContext context, FlashModel? flash) async {
    if (flashPriceCtrl.text.isEmpty) {
      context.showError('Enter Flash Amount');
      return 0;
    }
    if (flash == null) {
      context.showError('Error on Flash');
      return 0;
    }

    final updatedFlash = flash.copyWith(flashPrice: flashPriceCtrl.text.asInt);

    final res = await _repo.updateFlash(updatedFlash);

    res.fold((l) => Toaster.showFailure(l), (r) => Toaster.show(r));

    context.pop;
    flashPriceCtrl.clear();
  }

  _init([FlashModel? editingFlash]) async {
    if (editingFlash != null) {
      state.copyWith(editingFlash: editingFlash);
      flashPriceCtrl.text = editingFlash.flashPrice.toString();
    }
    final res = await _repo.fetchFlashProducts();
    res.fold((l) => Toaster.showFailure(l), (r) => _putData(r));
  }

  FlashRepo get _repo => _ref.read(flashRepoProvider);

  _putData(Stream<List<FlashModel>> stream) async {
    await for (final items in stream) {
      state = state.copyWith(flashList: AsyncValue.data(items));
    }
  }
}
