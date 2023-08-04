// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gngm/core/core.dart';

import 'package:gngm/feature/delivery/repo/delivery_repo.dart';
import 'package:gngm/models/models.dart';

final deliveryCtrlProvider = StateNotifierProvider.autoDispose<
    DeliveryCtrlNotifier, DeliveryChargeModel>((ref) {
  return DeliveryCtrlNotifier(ref).._init();
});

class DeliveryCtrlNotifier extends StateNotifier<DeliveryChargeModel> {
  DeliveryCtrlNotifier(this._ref) : super(DeliveryChargeModel.empty);

  final accessoryInsideCtrl = TextEditingController();
  final accessoryOutsideCtrl = TextEditingController();
  final phoneOutsideCtrl = TextEditingController();
  final phoneInsideCtrl = TextEditingController();

  final Ref _ref;

  _init() async {
    final charges = await _repo.getCharges();
    state = charges;
    accessoryInsideCtrl.text = charges.accessoryInside.toString();
    accessoryOutsideCtrl.text = charges.accessoryOutside.toString();
    phoneInsideCtrl.text = charges.phnInside.toString();
    phoneOutsideCtrl.text = charges.phnOutside.toString();
  }

  updateCharges(BuildContext context) async {
    context.showLoader();
    applyChanges();
    final res = await _repo.updateCharges(state);

    res.fold(
      (l) => context.showError(l.message),
      (r) => context.showSuccess(r),
    );
  }

  reload() async {
    await _init();
  }

  toggle(bool value) => state = state.copyWith(haveDelivery: value);

  applyChanges() {
    state = state.copyWith(
      accessoryInside: accessoryInsideCtrl.text.asInt,
      accessoryOutside: accessoryOutsideCtrl.text.asInt,
      phnInside: phoneInsideCtrl.text.asInt,
      phnOutside: phoneOutsideCtrl.text.asInt,
    );
  }

  DeliveryRepo get _repo => _ref.read(deliveryRepoProvider);
}
