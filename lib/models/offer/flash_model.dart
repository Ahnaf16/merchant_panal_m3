import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gngm/core/core.dart';

import 'package:gngm/models/models.dart';

class FlashModel {
  FlashModel({
    required this.name,
    required this.price,
    required this.flashPrice,
    required this.image,
    required this.id,
    required this.category,
    required this.priority,
  });

  // factory FlashModel.fromDoc(DocumentSnapshot doc) {
  //   return FlashModel(
  //     name: '', // doc['name'],
  //     price: 0, //doc['price'],
  //     flashPrice: 0, // doc['flash'],
  //     image: '', //doc['img'],
  //     id: '', //doc['id'],
  //     category: '', // doc['category'],
  //     priority: 0, // doc.containsKey('priority') ? doc['priority'] : 1,
  //   );
  // }

  factory FlashModel.fromDoc(DocumentSnapshot doc) {
    return FlashModel(
      name: doc['name'],
      price: doc['price'],
      flashPrice: doc['flash'],
      image: doc['img'],
      id: doc['id'],
      category: doc['category'],
      priority: doc.containsKey('priority') ? doc['priority'] : 1,
    );
  }

  factory FlashModel.fromProduct(ProductModel product) {
    return FlashModel(
      name: product.name,
      price: product.price,
      flashPrice: 0,
      image: product.imgUrls.first,
      id: product.id,
      category: product.category,
      priority: 1,
    );
  }
  static FlashModel empty = FlashModel(
    name: '',
    price: 0,
    flashPrice: 0,
    image: '',
    id: '',
    category: '',
    priority: 1,
  );

  final String category;
  final int flashPrice;
  final String id;
  final String image;
  final String name;
  final int price;
  final int priority;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'category': category});
    result.addAll({'flash': flashPrice});
    result.addAll({'priority': priority});
    result.addAll({'id': id});
    result.addAll({'img': image});
    result.addAll({'name': name});
    result.addAll({'price': price});

    return result;
  }

  FlashModel copyWith({
    String? category,
    int? flashPrice,
    String? id,
    String? image,
    String? name,
    int? price,
    int? priority,
  }) {
    return FlashModel(
      category: category ?? this.category,
      flashPrice: flashPrice ?? this.flashPrice,
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      price: price ?? this.price,
      priority: priority ?? this.priority,
    );
  }
}
