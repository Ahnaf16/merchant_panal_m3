import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:gngm/core/core.dart';
import 'package:gngm/models/models.dart';

final realTimeVersionProvider = StreamProvider<AppVersionModel>((ref) async* {
  final fire = FirebaseFirestore.instance;

  final pack = await PackageInfo.fromPlatform();

  final version = pack.version.replaceAll('.', '').asInt;
  final buildNo = pack.buildNumber.asInt;

  yield* fire
      .collection(FirePath.appConfig)
      .doc(FirePath.appUpdate)
      .snapshots()
      .map((doc) => AppVersionModel.fromDoc(doc)
          .copyWith(versionNo: version, buildNo: buildNo));
});

final progressVAlueProvider = StateProvider<UpDownProgressValue>((ref) {
  return UpDownProgressValue(0);
});
