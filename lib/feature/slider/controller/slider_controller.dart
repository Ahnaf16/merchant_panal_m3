// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/models/slider/slider_model.dart';
import 'package:nanoid/nanoid.dart';

import '../../../core/core.dart';
import '../repository/slider_repository.dart';

final slideImageStateProvider = StateProvider.autoDispose<PlatformFile?>((ref) {
  return null;
});

final slideCtrlProvider =
    StateNotifierProvider<SliderControllerNotifier, SliderModel>((ref) {
  return SliderControllerNotifier(ref);
});

class SliderControllerNotifier extends StateNotifier<SliderModel> {
  SliderControllerNotifier(this._ref) : super(SliderModel.empty);
  SliderRepository get _repo => _ref.read(sliderRepoProvider);

  final Ref _ref;

  selectImage() async {
    final picker = _ref.watch(filePickerProvider);
    final files = await picker.pickImage();
    files.fold(
      (l) => Toaster.showFailure(l),
      (r) => _ref.read(slideImageStateProvider.notifier).update((state) => r),
    );
  }

  onImageDropped(PlatformFile file) async =>
      _ref.read(slideImageStateProvider.notifier).update((state) => file);

  removeImage(bool isFile) {
    if (isFile) {
      _ref.read(slideImageStateProvider.notifier).update((state) => null);
    } else {
      state = state.copyWith(img: '');
    }
  }

  //
  addSlider(BuildContext context) async {
    state = state.copyWith(id: nanoid().replaceAll('/', '_'));

    final uploader = _ref.watch(fileUploaderProvider);
    final imgFile = _ref.read(slideImageStateProvider);

    if (imgFile == null && state.img.isEmpty) {
      context.showError('No image file is provided');
      return 0;
    }
    context.showLoader();

    if (imgFile != null) {
      final imgUrl = await uploader.uploadImage(
        fileName: state.id,
        storagePath: StoragePath.slider,
        imagePath: imgFile,
      );
      imgUrl.fold(
        (l) => Toaster.showFailure(l),
        (r) {
          _ref.read(slideImageStateProvider.notifier).update((state) => null);
          state = state.copyWith(img: r);
        },
      );
    }
    if (state.img.isEmpty) {
      context.showError('No image is provided');
      return 0;
    }
    final res = await _repo.addSlider(state);
    res.fold(
      (l) => context.showError(l.message),
      (r) => context.showSuccess(r),
    );

    context.pop;
    context.pop;
  }

  reset() {
    state = SliderModel.empty;
    _ref.read(slideImageStateProvider.notifier).update((state) => null);
  }

  deleteSlider(SliderModel slider) async {
    final uploader = _ref.watch(fileUploaderProvider);

    final res = await _repo.deleteSlider(slider.id);
    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show('Slider Delete'),
    );
    log(slider.id);
    final upLoaderRes = await uploader.deleteImage(
      storagePath: StoragePath.slider,
      fileName: slider.id,
    );
    upLoaderRes.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show('Image Delete'),
    );
  }
}
