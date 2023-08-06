// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merchant_m3/core/core.dart';

import '../models.dart';

class CartModel {
  CartModel({
    required this.category,
    required this.id,
    required this.img,
    required this.inStock,
    required this.isSelected,
    required this.name,
    required this.price,
    required this.quantity,
    this.variant = '',
    this.imei = '',
  }) : total = price * quantity;

  factory CartModel.fromDoc(DocumentSnapshot doc) {
    return CartModel(
      id: doc.id,
      img: doc['img'],
      name: doc['productName'],
      price: doc['productPrice'],
      quantity: doc['quantity'],
      isSelected: doc['isSelected'],
      category: doc['category'],
      inStock: doc['inStock'],
      variant: doc.containsKey('variant') ? doc['variant'] : '',
      imei: doc.containsKey('imei') ? doc['imei'] : '',
    );
  }

  factory CartModel.fromFlash(FlashModel item) {
    return CartModel(
      id: item.id,
      name: item.name,
      price: item.flashPrice,
      img: item.image,
      quantity: 1,
      isSelected: false,
      category: item.category,
      inStock: true,
    );
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['productId'],
      img: map['img'],
      name: map['productName'],
      price: map['productPrice'],
      quantity: map['quantity'],
      isSelected: map['isSelected'],
      category: map['category'],
      inStock: map.containsKey('inStock') ? map['inStock'] : true,
      imei: map.containsKey('imei') ? map['imei'] : '',
      variant: map.containsKey('variant') ? map['variant'] : '',
    );
  }

  factory CartModel.fromProduct(ProductModel item) {
    return CartModel(
      id: item.id,
      name: item.name,
      variant: item.variant,
      price: item.haveDiscount ? item.discountPrice : item.price,
      img: item.imgUrls.first,
      quantity: 1,
      isSelected: false,
      category: item.category,
      inStock: item.inStock,
    );
  }

  static CartModel empty = CartModel(
    category: '',
    id: '',
    img: '',
    name: '',
    price: 0,
    quantity: 1,
    isSelected: false,
    inStock: true,
    imei: '',
    variant: '',
  );

  final String category;
  final String id;
  final String img;
  final bool inStock;
  final bool isSelected;
  final String name;
  final int price;
  final int quantity;
  final int total;
  final String variant;
  final String imei;

  int get selectedTotal => isSelected ? (price * quantity) : 0;

  Map<String, dynamic> toMap() => {
        'productId': id,
        'productName': name,
        'productPrice': price,
        'img': img,
        'quantity': quantity,
        'isSelected': isSelected,
        'category': category,
        'inStock': inStock,
        'imei': imei,
        'variant': variant,
      };

  CartModel copyWith({
    String? category,
    String? id,
    String? img,
    bool? isSelected,
    String? name,
    int? price,
    int? quantity,
    bool? inStock,
    String? imei,
    String? variant,
  }) {
    return CartModel(
      category: category ?? this.category,
      id: id ?? this.id,
      img: img ?? this.img,
      isSelected: isSelected ?? this.isSelected,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      inStock: inStock ?? this.inStock,
      imei: imei ?? this.imei,
      variant: variant ?? this.variant,
    );
  }
}
