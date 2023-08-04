import 'package:cloud_firestore/cloud_firestore.dart';

class AppVersionModel {
  AppVersionModel({
    this.buildNo = 0,
    this.versionNo = 0,
    required this.merchantVersion,
    required this.clientVersion,
    required this.merchantURL,
  });

  factory AppVersionModel.fromDoc(DocumentSnapshot doc) {
    return AppVersionModel(
      merchantVersion: doc['merchantVersion'],
      clientVersion: doc['addedVersion'],
      merchantURL: doc['appURL'],
    );
  }

  static AppVersionModel empty = AppVersionModel(
    merchantURL: '',
    buildNo: 0,
    versionNo: 0,
    merchantVersion: 0,
    clientVersion: 0,
  );

  /// Current Version
  final int versionNo;

  /// Current Build No
  final int buildNo;

  /// Current Version from backend
  final double merchantVersion;

  /// Latest App url for Merchant
  final String merchantURL;

  /// Current Version from backend
  final double clientVersion;

  bool get canUpdateMerchant =>
      merchantVersion > double.parse('$versionNo.$buildNo');

  /// Current Version from backend parsed
  String get fullVersion {
    String version = merchantVersion.toString();

    final split = version.split('.');

    return '${split.first.replaceAll('', '.').replaceFirst('.', '')}+${split.last}'
        .replaceAll('.+', '+');
  }

  String get currentVersion {
    final version = versionNo.toString();

    return '${version.replaceAll('', '.').replaceFirst('.', '')}+$buildNo'
        .replaceAll('.+', '+');
  }

  AppVersionModel copyWith({
    int? buildNo,
    int? versionNo,
    double? merchantVersion,
    double? clientVersion,
    String? appURL,
  }) {
    return AppVersionModel(
      buildNo: buildNo ?? this.buildNo,
      versionNo: versionNo ?? this.versionNo,
      merchantVersion: merchantVersion ?? this.merchantVersion,
      clientVersion: clientVersion ?? this.clientVersion,
      merchantURL: appURL ?? merchantURL,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'merchantVersion': merchantVersion});
    result.addAll({'addedVersion': clientVersion});
    result.addAll({'appURL': merchantURL});

    return result;
  }

  @override
  String toString() {
    return '''
AppVersionModel =>
  appURL: $merchantURL,
  clientVersion: $clientVersion,
  ------------------------
  versionNo : $versionNo
  buildNo : $buildNo,
  merchantVersion : $merchantVersion,
   -----------------------------
  can Update => $canUpdateMerchant,
''';
  }
}

class UpDownProgressValue {
  UpDownProgressValue(
    this.value,
  ) : status = _getStatus(value);

  static ProgressStatus _getStatus(double value) {
    if (value.isNegative) return ProgressStatus.started;
    if (value > 0.0 && value < 1.0) return ProgressStatus.started;
    if (value >= 1.0) return ProgressStatus.complete;
    return ProgressStatus.notStarted;
  }

  final ProgressStatus status;
  final double value;

  UpDownProgressValue copyWith(double? value) {
    return UpDownProgressValue(
      value ?? this.value,
    );
  }
}

enum ProgressStatus { notStarted, started, complete }
