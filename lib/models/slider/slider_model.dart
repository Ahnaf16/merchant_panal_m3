import 'package:cloud_firestore/cloud_firestore.dart';

class SliderModel {
  SliderModel({
    required this.img,
    required this.id,
  });

  factory SliderModel.fromDoc(DocumentSnapshot doc) {
    return SliderModel(
      img: doc['img'] as String,
      id: doc.id,
    );
  }
  static SliderModel empty = SliderModel(img: '', id: '');

  final String id;
  final String img;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'img': img,
      'id': id,
    };
  }

  SliderModel copyWith({
    String? id,
    String? img,
  }) {
    return SliderModel(
      id: id ?? this.id,
      img: img ?? this.img,
    );
  }
}
