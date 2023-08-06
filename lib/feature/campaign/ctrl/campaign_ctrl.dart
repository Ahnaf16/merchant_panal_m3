// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/campaign/repo/campaign_repo.dart';
import 'package:merchant_m3/models/models.dart';

final campaignImageStateProvider =
    StateProvider.autoDispose<PlatformFile?>((ref) {
  return null;
});

final campaignEditCtrlProvider = StateNotifierProvider.autoDispose
    .family<CampaignEditCtrlNotifier, CampaignStateModel, String?>(
        (ref, updatingId) {
  return CampaignEditCtrlNotifier(ref, updatingId).._init();
});

class CampaignEditCtrlNotifier extends StateNotifier<CampaignStateModel> {
  CampaignEditCtrlNotifier(this._ref, this.title)
      : super(CampaignStateModel.empty);

  final String? title;
  final titleCtrl = TextEditingController();

  final Ref _ref;

  _init() async {
    if (title != null) {
      final campaign = await _repo.getCampaign(title!);
      final campaignItem = await _repo.getCampaignItems(title!);
      state = state.copyWith(
        campaign: campaign,
        products: [...campaignItem],
        removedProducts: [],
      );
      titleCtrl.text = state.campaign.title;
    } else {
      state = CampaignStateModel.empty;
      titleCtrl.clear();
    }
  }

  reload() async {
    await _init();
  }

  uploadCampaign(BuildContext context, bool isUpdate) async {
    final uploader = _ref.watch(fileUploaderProvider);
    final imgFile = _ref.read(campaignImageStateProvider);

    context.showLoader();
    if (state.products.isEmpty) {
      context.showError('No product added');
      return 0;
    }
    state = state.copyWith(
      campaign: state.campaign.copyWith(title: titleCtrl.text),
    );
    if (imgFile == null && state.campaign.image.isEmpty) {
      context.showError('No image file is provided');
      return 0;
    }

    if (imgFile != null) {
      final imgUrl = await uploader.uploadImage(
        fileName: state.campaign.title,
        storagePath: StoragePath.campaign,
        imagePath: imgFile,
      );
      imgUrl.fold(
        (l) => Toaster.showFailure(l),
        (r) {
          _ref
              .read(campaignImageStateProvider.notifier)
              .update((state) => null);
          state = state.copyWith(campaign: state.campaign.copyWith(image: r));
        },
      );
    }
    if (state.campaign.image.isEmpty) {
      context.showError('No image is provided');
      return 0;
    }

    final res = isUpdate
        ? await _repo.updateCampaign(state)
        : await _repo.addCampaign(state);

    res.fold(
      (l) => context.showError(l.message),
      (r) =>
          context.showSuccess(isUpdate ? 'Campaign Updated' : 'Campaign Added'),
    );
  }

  updatePriority(CampaignModel campaign, bool isUp) async {
    final res = await _repo.updatePriority(campaign, isUp);
    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show(isUp ? 'Campaign Moved Up' : 'Campaign Moved Down'),
    );
  }

  deleteCampaign(CampaignModel campaign) async {
    final uploader = _ref.watch(fileUploaderProvider);

    final res = await _repo.deleteCampaign(campaign.title);
    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show('Campaign Deleted'),
    );

    final upLoaderRes = await uploader.deleteImage(
      storagePath: StoragePath.campaign,
      fileName: campaign.title,
    );

    upLoaderRes.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show('Campaign Image Deleted'),
    );
  }

  selectImage() async {
    final picker = _ref.watch(filePickerProvider);
    final files = await picker.pickImage();
    files.fold(
      (l) => Toaster.showFailure(l),
      (r) =>
          _ref.read(campaignImageStateProvider.notifier).update((state) => r),
    );
  }

  onImageDrop(PlatformFile file) async =>
      _ref.read(campaignImageStateProvider.notifier).update((state) => file);

  removeImage(bool isFile) {
    if (isFile) {
      _ref.read(campaignImageStateProvider.notifier).update((state) => null);
    } else {
      state = state.copyWith(campaign: state.campaign.copyWith(image: ''));
    }
  }

  addProduct(ProductModel product) {
    state = state.copyWith(
      products: [...state.products, CampaignItemModel.fromProduct(product)],
    );
  }

  removeProduct(CampaignItemModel product) {
    final index = state.products.indexOf(product);

    state = state.copyWith(
      removedProducts: [...state.removedProducts, product.docId],
      products: [
        ...state.products.sublist(0, index),
        ...state.products.sublist(index + 1)
      ],
    );
  }

  CampaignRepo get _repo => _ref.read(campaignRepoProvider);
}
