import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/version_manager/provider/app_version_provider.dart';
import 'package:merchant_m3/feature/version_manager/repo/app_version_repo.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:open_filex/open_filex.dart';
import 'package:universal_html/html.dart' as html;

final merchantAPKFileProvider = StateProvider<PlatformFile?>((ref) {
  return null;
});

final appVersionProvider =
    StateNotifierProvider<AppVersionNotifier, AppVersionModel>(
  (ref) => AppVersionNotifier(ref).._init(),
);

class AppVersionNotifier extends StateNotifier<AppVersionModel> {
  AppVersionNotifier(this._ref) : super(AppVersionModel.empty);

  final Ref _ref;

  final clientVersionCtrl = TextEditingController();
  final merchantVersionCtrl = TextEditingController();
  final merchantLinkCtrl = TextEditingController();

  _init() async {
    final fetched = await _repo.fetchVersion();
    state = fetched;
    clientVersionCtrl.text = state.clientVersion.toString();
    merchantVersionCtrl.text = fetched.merchantVersion.toString();
    merchantLinkCtrl.text = fetched.merchantURL;
  }

  downloadNewVersion(AppVersionModel version) async {
    final dio = Dio();

    UpDownProgressValue downloadProgress = UpDownProgressValue(-1);
    final fileName = LocalPath.androidDownloadDir('${version.fullVersion}.apk');
    _setValue(downloadProgress);
    try {
      await dio.download(
        version.merchantURL,
        fileName,
        onReceiveProgress: (rcv, total) {
          final progress = ((rcv / total) * 100) / 100;
          downloadProgress = downloadProgress.copyWith(progress);
          _setValue(downloadProgress);
        },
      );
    } on DioException catch (e) {
      log(e.toString());
    }
  }

  void _setValue(UpDownProgressValue downloadProgress) {
    _ref
        .read(progressVAlueProvider.notifier)
        .update((state) => downloadProgress);
  }

  openApk(AppVersionModel version) async {
    final fileName = LocalPath.androidDownloadDir('${version.fullVersion}.apk');

    OpenFilex.open(fileName, type: "application/vnd.android.package-archive");
  }

  reloadWebToUpdateCatch() {
    if (kIsWeb) {
      html.window.location.reload();
    }
  }

  reload() {
    _init();
    setFile(null);
  }

  incrementVersion(bool isAdd, bool isClient) {
    List splitVersion = [];

    final original = isClient
        ? clientVersionCtrl.text.split('.')
        : merchantVersionCtrl.text.split('.');

    for (String element in original) {
      final value = switch (isAdd) {
        true => element.asInt + 1,
        false => element.asInt - 1,
      };

      splitVersion.add(value);
    }

    final updated = splitVersion.join('.');

    if (isClient) {
      clientVersionCtrl.text = updated.toString();
    } else {
      merchantVersionCtrl.text = updated.toString();
    }
  }

  selectApkFile() async {
    final picker = _ref.watch(filePickerProvider);

    final res = await picker.pickFile(allowedExtensions: ['apk']);

    res.fold(
      (l) => Toaster.showFailure(l),
      (r) => setFile(r),
    );
  }

  uploadSelectedFile(BuildContext context) async {
    final selected = _ref.watch(merchantAPKFileProvider);
    final uploader = _ref.watch(fileUploaderProvider);

    if (selected == null) {
      context.showError('No File Selected');
      return 0;
    }

    context.showLoader();
    final res = await uploader.uploadFile(
      storagePath: StoragePath.app,
      file: selected,
      fileName: 'gngm_V${state.fullVersion}',
      extension: '.apk',
    );
    res.fold(
      (l) => context.showError(l.message),
      (r) async {
        merchantLinkCtrl.text = r;
        await submitVersion(context);
        context.showSuccess('Uploading successful');
      },
    );
  }

  submitVersion(BuildContext context) async {
    state = state.copyWith(
      clientVersion: clientVersionCtrl.text.asDouble,
      merchantVersion: merchantVersionCtrl.text.asDouble,
      appURL: merchantLinkCtrl.text,
    );
    context.showLoader();
    final res = await _repo.updateVersion(state);

    res.fold(
      (l) => context.showError(l.message),
      (r) => context.showSuccess(r),
    );
    _init();
  }

  setFile(PlatformFile? file) =>
      _ref.read(merchantAPKFileProvider.notifier).update((state) => file);

  AppVersionRepo get _repo => _ref.read(appVersionRepoProvider);
}
