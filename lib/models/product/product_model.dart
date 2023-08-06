// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:merchant_m3/core/extensions/helper_extension.dart';
import 'package:merchant_m3/feature/auth/provider/auth_provider.dart';

class ProductModel extends Equatable {
  ProductModel({
    required this.name,
    required this.brand,
    required this.price,
    required this.discountPrice,
    required this.haveDiscount,
    required this.imgUrls,
    required this.description,
    required this.category,
    required this.inStock,
    required this.id,
    required this.date,
    required this.employeeName,
    required this.priority,
    required this.specifications,
    required this.isEnabled,
    this.isDuplicate = false,
  }) : variant = _getVariant(specifications);

  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    return ProductModel(
      id: doc.id,
      name: doc['name'],
      brand: doc['brand'],
      price: doc['price'],
      discountPrice: doc['discount_price'],
      haveDiscount: doc['haveDiscount'],
      imgUrls: doc['imgs'],
      description: doc['product_desc'],
      category: doc['category'],
      date: (doc['date'] as Timestamp).toDate(),
      employeeName: doc['Employee']['name'],
      inStock: doc['inStock'],
      priority: doc['preority'],
      specifications: doc['specifications'],
      isDuplicate: (doc.data() as Map).containsKey('isDuplicate')
          ? doc['isDuplicate']
          : false,
      isEnabled: (doc.data() as Map).containsKey('isEnabled')
          ? doc['isEnabled']
          : true,
    );
  }

  static ProductModel empty = ProductModel(
    name: '',
    brand: '',
    price: 0,
    discountPrice: 0,
    haveDiscount: false,
    imgUrls: const [],
    description: '',
    category: '',
    inStock: true,
    id: '',
    date: DateTime.now(),
    employeeName: getUser?.displayName ?? 'noName',
    priority: 1,
    specifications: const {},
    isEnabled: true,
  );

  final String brand;
  final String category;
  final DateTime date;
  final String description;
  final int discountPrice;
  final String employeeName;
  final bool haveDiscount;
  final String id;
  final List imgUrls;
  final bool inStock;
  final bool isDuplicate;
  final bool isEnabled;
  final String name;
  final int price;
  final int priority;
  final Map<String, dynamic> specifications;
  final String variant;

  @override
  List<Object> get props {
    return [
      id,
      name,
      price,
      discountPrice,
      haveDiscount,
      brand,
      imgUrls,
      description,
      specifications,
      category,
      inStock,
      employeeName,
      priority,
      variant,
      isDuplicate,
      isEnabled,
    ];
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'brand': brand,
        'price': price,
        'discount_price': discountPrice,
        'haveDiscount': haveDiscount,
        'imgs': imgUrls,
        'product_desc': description,
        'category': category,
        'inStock': inStock,
        'date': date,
        'Employee': {
          'name': employeeName,
        },
        'specifications': specifications,
        'isDuplicate': isDuplicate,
        'preority': priority,
        'id': id,
        'isEnabled': isEnabled,
      };

  ProductModel copyWith({
    String? id,
    String? name,
    int? price,
    int? discountPrice,
    bool? haveDiscount,
    String? brand,
    List? imgUrls,
    String? description,
    Map<String, dynamic>? specifications,
    String? category,
    bool? inStock,
    DateTime? date,
    String? employeeName,
    int? priority,
    bool? isDuplicate,
    bool? isEnabled,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      haveDiscount: haveDiscount ?? this.haveDiscount,
      brand: brand ?? this.brand,
      imgUrls: imgUrls ?? this.imgUrls,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
      category: category ?? this.category,
      inStock: inStock ?? this.inStock,
      date: date ?? this.date,
      employeeName: employeeName ?? this.employeeName,
      priority: priority ?? this.priority,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  static String _getVariant(Map<String, dynamic> specifications) {
    return specifications.isEmpty
        ? 'Variant : N/A'
        : specifications['RAM'] == null || specifications['RAM'] == null
            ? 'Variant : N/A'
            : 'Variant : ${specifications['RAM']}, ${specifications['Storage']}';
  }
}

extension ProductEx on ProductModel {
  Widget get pricingWidget => Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          Text(
            price.toCurrency(),
            style: TextStyle(
              fontSize: haveDiscount ? 15 : 18,
              fontWeight: haveDiscount ? null : FontWeight.bold,
              decoration: haveDiscount ? TextDecoration.lineThrough : null,
            ),
          ),
          if (haveDiscount)
            Text(
              discountPrice.toCurrency(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      );
}

extension PriceEx on Text {
  Text withDiscount(int discount, bool haveDiscount) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: data,
            style: TextStyle(
              fontSize: haveDiscount ? 15 : 18,
              fontWeight: haveDiscount ? null : FontWeight.bold,
              decoration: haveDiscount ? TextDecoration.lineThrough : null,
            ),
          ),
          if (haveDiscount)
            TextSpan(
              text: '  ${discount.toCurrency()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
