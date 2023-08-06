// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/employee/provider/employee_provider.dart';
import 'package:merchant_m3/feature/employee/repo/employee_repo.dart';
import 'package:merchant_m3/models/models.dart';

final employeeImageStateProvider =
    StateProvider.autoDispose<PlatformFile?>((ref) {
  return null;
});

final employeeCtrlProvider = StateNotifierProvider.autoDispose
    .family<EmployeeCtrlNotifier, EmployeeModel, String?>((ref, employeeId) {
  return EmployeeCtrlNotifier(ref, employeeId).._init();
});

class EmployeeCtrlNotifier extends StateNotifier<EmployeeModel> {
  EmployeeCtrlNotifier(this._ref, this.employeeId) : super(EmployeeModel.empty);

  final String? employeeId;

  final emailCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final Ref _ref;

  _init() async {
    if (employeeId != null) {
      final employee = await _repo.getEmployee(employeeId!);
      state = employee;
      emailCtrl.text = employee.email;
      nameCtrl.text = employee.name;
      passCtrl.text = employee.password;
    }
  }

  setPermission(EPermissions permission) {
    final permissions = state.permissions.toList();

    if (permissions.contains(permission)) {
      permissions.removeWhere((element) => element == permission);

      state = state.copyWith(permissions: permissions);
    } else {
      permissions.add(permission);
      state = state.copyWith(permissions: permissions);
    }
  }

  bool get doseContainsEvery => EPermissions.values
      .every((element) => state.permissions.contains(element));

  addAllPermission() {
    if (doseContainsEvery) {
      state = state.copyWith(permissions: []);
    } else {
      state = state.copyWith(permissions: EPermissions.values);
    }
  }

  selectImage() async {
    final picker = _ref.watch(filePickerProvider);
    final files = await picker.pickImage();
    files.fold(
      (l) => Toaster.showFailure(l),
      (r) => changeImageState(r),
    );
  }

  removeImage(bool isFile) {
    if (isFile) {
      changeImageState(null);
    } else {
      state = state.copyWith(photo: '');
    }
  }

  createUpdateEmployee(BuildContext context, bool isUpdate) async {
    final uploader = _ref.watch(fileUploaderProvider);
    final imgFile = _ref.read(employeeImageStateProvider);
    if (nameCtrl.text.isEmpty) {
      context.showError('Insert Name');
      return 0;
    }
    if (emailCtrl.text.isEmpty) {
      context.showError('Insert Email');
      return 0;
    }
    if (!emailCtrl.text.isEmail) {
      context.showError('Insert valid Email');
      return 0;
    }
    if (passCtrl.text.isEmpty) {
      context.showError('Insert Password');
      return 0;
    }
    if (imgFile == null && state.photo.isEmpty) {
      context.showError('No image file is provided');
      return 0;
    }
    applyState();
    context.showLoader();

    if (imgFile != null) {
      final imgUrl = await uploader.uploadImage(
        fileName: state.email,
        storagePath: StoragePath.employee,
        imagePath: imgFile,
      );
      imgUrl.fold(
        (l) => Toaster.showFailure(l),
        (r) {
          changeImageState(null);
          state = state.copyWith(photo: r);
        },
      );
    }
    if (state.photo.isEmpty) {
      context.showError('No image is provided');
      return 0;
    }

    try {
      context.showLoader();
      final res = isUpdate
          ? await _repo.updateEmployee(state)
          : await _repo.createEmployee(state);

      res.fold(
        (l) => context.showError(l.message),
        (r) => context.showSuccess(r),
      );
      return _ref.refresh(loggedInEmployeeProvider);
    } on FirebaseAuthException catch (e) {
      context.showError(e.message ?? 'Something went wrong');
      log(e.message.toString());
    }
  }

  deleteEmployee(String id) async {
    final res = await _repo.deleteEmployee(id);

    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => Toaster.show(r),
    );
  }

  instantLogin(EmployeeModel employee) async {
    await _repo.instantLogin(employee);
    return _ref.refresh(loggedInEmployeeProvider);
  }

  void applyState() {
    state = state.copyWith(
      name: nameCtrl.text,
      email: emailCtrl.text,
      password: passCtrl.text,
    );
  }

  void changeImageState(PlatformFile? img) {
    _ref.read(employeeImageStateProvider.notifier).update((state) => img);
  }

  EmployeeRepo get _repo => _ref.watch(employeeRepoProvider);
}
