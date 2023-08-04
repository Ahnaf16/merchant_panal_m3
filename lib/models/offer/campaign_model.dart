// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gngm/core/core.dart';

import 'package:gngm/models/models.dart';

//! for campaign the title is used as id
class CampaignModel {
  const CampaignModel({
    required this.image,
    required this.title,
    required this.priority,
  });

  factory CampaignModel.fromDoc(DocumentSnapshot doc) {
    return CampaignModel(
      image: doc['img'],
      title: doc['title'],
      priority: doc.containsKey('priority') ? doc['priority'] : 1,
    );
  }

  static const CampaignModel empty =
      CampaignModel(image: '', title: '', priority: 1);

  final String image;
  final String title;
  final int priority;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'img': image});
    result.addAll({'title': title});
    result.addAll({'priority': priority});

    return result;
  }

  CampaignModel copyWith({
    String? image,
    String? title,
    int? preority,
  }) {
    return CampaignModel(
      image: image ?? this.image,
      title: title ?? this.title,
      priority: preority ?? priority,
    );
  }
}

class CampaignItemModel {
  CampaignItemModel({
    required this.img,
    required this.name,
    required this.price,
    required this.productId,
    required this.discount,
    required this.haveDiscount,
    this.docId = '',
  });

  factory CampaignItemModel.fromDoc(DocumentSnapshot doc) {
    return CampaignItemModel(
      img: doc['img'],
      name: doc['name'],
      price: doc['price'],
      productId: doc['id'],
      discount: doc['discount'],
      haveDiscount: doc['haveDiscount'],
      docId: doc.id,
    );
  }

  factory CampaignItemModel.fromProduct(ProductModel product) {
    return CampaignItemModel(
      img: product.imgUrls.first,
      name: product.name,
      price: product.price,
      productId: product.id,
      discount: product.discountPrice,
      haveDiscount: product.haveDiscount,
    );
  }

  final int discount;
  final String docId;
  final bool haveDiscount;
  final String img;
  final String name;
  final int price;
  final String productId;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'discount': discount});
    result.addAll({'docId': docId});
    result.addAll({'haveDiscount': haveDiscount});
    result.addAll({'img': img});
    result.addAll({'name': name});
    result.addAll({'price': price});
    result.addAll({'id': productId});

    return result;
  }

  CampaignItemModel copyWith({
    String? img,
    String? name,
    int? price,
    int? discount,
    bool? haveDiscount,
    String? id,
  }) {
    return CampaignItemModel(
      img: img ?? this.img,
      name: name ?? this.name,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      haveDiscount: haveDiscount ?? this.haveDiscount,
      productId: id ?? productId,
    );
  }
}

class CampaignStateModel {
  const CampaignStateModel({
    required this.campaign,
    required this.products,
    required this.removedProducts,
  });

  final CampaignModel campaign;
  final List<CampaignItemModel> products;
  final List<String> removedProducts;

  CampaignStateModel copyWith({
    CampaignModel? campaign,
    List<CampaignItemModel>? products,
    List<String>? removedProducts,
  }) {
    return CampaignStateModel(
      campaign: campaign ?? this.campaign,
      products: products ?? this.products,
      removedProducts: removedProducts ?? this.removedProducts,
    );
  }

  static CampaignStateModel empty = const CampaignStateModel(
    campaign: CampaignModel.empty,
    products: [],
    removedProducts: [],
  );
}
