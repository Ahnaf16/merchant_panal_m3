import 'package:cloud_firestore/cloud_firestore.dart';

class GSheetCredModel {
  final String id;
  final String key;
  final String backupId;

  GSheetCredModel({
    required this.id,
    required this.key,
    required this.backupId,
  });

  factory GSheetCredModel.fromDoc(DocumentSnapshot doc) {
    return GSheetCredModel(
      id: doc['id'],
      key: doc['key'],
      backupId: doc['backupId'],
    );
  }

  @override
  String toString() =>
      'SheetsCredModel(id: $id, key: $key, backupId: $backupId)';
}
