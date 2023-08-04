import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/models/models.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appVersionRepoProvider = Provider.autoDispose<AppVersionRepo>((ref) {
  return AppVersionRepo();
});

class AppVersionRepo {
  final _fire = FirebaseFirestore.instance;

  Future<PackageInfo> get _packInfo async => await PackageInfo.fromPlatform();

  DocumentReference get _doc =>
      _fire.collection(FirePath.appConfig).doc(FirePath.appUpdate);

  Future<AppVersionModel> fetchVersion() async {
    final pack = await _packInfo;

    final version = pack.version.replaceAll('.', '').asInt;
    final buildNo = pack.buildNumber.asInt;

    final snap = await _doc.get();

    return AppVersionModel.fromDoc(snap)
        .copyWith(versionNo: version, buildNo: buildNo);
  }

  FutureEither<String> updateVersion(AppVersionModel appVersion) async {
    try {
      await _doc.update(appVersion.toMap());

      return right('Version Updated');
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }
}
