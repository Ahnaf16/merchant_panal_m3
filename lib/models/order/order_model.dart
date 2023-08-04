// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:gngm/core/core.dart';
import 'package:gngm/feature/auth/provider/auth_provider.dart';
import 'package:gngm/models/models.dart';

class OrderModel extends Equatable {
  OrderModel({
    this.docID = '',
    required this.invoice,
    required this.address,
    required this.products,
    required this.paidAmount,
    required this.paymentMethod,
    required this.status,
    required this.orderDate,
    required this.user,
    required this.timeLine,
    required this.deliveryCharge,
    required this.voucher,
    required this.lastMod,
    required this.lastModBy,
    required this.bkashData,
    required this.gCoinUsed,
    required this.goProtectType,
  }) : subTotal = products.map((e) => e.total).sum;

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    return OrderModel(
      docID: doc.id,
      invoice: doc['invoice'],
      paymentMethod: PaymentMethods.fromString(doc['paymentMethod']),
      status: OrderStatus.fromString(doc['status']),
      orderDate: (doc['orderDate'] as Timestamp).toDate(),
      address: AddressModel.fromMap(doc['address']),
      user: UserModel.fromMap(doc['user']),
      products: (doc['items'] as List<dynamic>)
          .map((item) => CartModel.fromMap(item))
          .toList(),
      timeLine: (doc['timeLine'] as List<dynamic>)
          .map((item) => OrderTimelineModel.fromMap(item))
          .toList(),
      paidAmount: doc['paidAmount'],
      deliveryCharge: doc['deliveryCharge'],
      voucher: doc.containsKey('voucher') ? doc['voucher'] : 0,
      lastMod: doc.containsKey('lastMod')
          ? (doc['lastMod'] as Timestamp).toDate()
          : DateTime(2022, 1, 1),
      lastModBy: doc.containsKey('lastModBy') ? doc['lastModBy'] : '',
      gCoinUsed: doc.containsKey('gCoinUsed') ? doc['gCoinUsed'] : 0,
      bkashData: doc.containsKey('bkashData')
          ? doc['bkashData'] != null
              ? BkashPaymentModel.fromMap(doc['bkashData'])
              : null
          : null,
      goProtectType: doc.containsKey('goProtectType')
          ? doc['goProtectType'] != null
              ? GoProtectType.fromMap(doc['goProtectType'])
              : null
          : null,
    );
  }

  static OrderModel empty = OrderModel(
    invoice: '',
    paymentMethod: PaymentMethods.notSelected,
    status: OrderStatus.pending,
    orderDate: DateTime.now(),
    address: AddressModel.empty,
    user: UserModel.empty,
    products: const [],
    timeLine: [OrderTimelineModel.empty],
    paidAmount: 0,
    deliveryCharge: 0,
    voucher: 0,
    lastMod: DateTime.now(),
    lastModBy: getUser?.displayName ?? 'noName',
    bkashData: null,
    gCoinUsed: 0,
    goProtectType: null,
  );

  final AddressModel address;
  final BkashPaymentModel? bkashData;
  final int deliveryCharge;
  final String docID;
  final int gCoinUsed;
  final GoProtectType? goProtectType;
  final String invoice;
  final DateTime lastMod;
  final String lastModBy;
  final DateTime orderDate;
  final int paidAmount;
  final PaymentMethods paymentMethod;
  final List<CartModel> products;
  final OrderStatus status;
  final int subTotal;
  final List<OrderTimelineModel> timeLine;
  final UserModel user;
  final int voucher;

  @override
  List<Object?> get props => [
        docID,
        invoice,
        paidAmount,
        paymentMethod,
        status,
        orderDate,
        deliveryCharge,
        voucher,
        bkashData,
        gCoinUsed,
        goProtectType,
      ];

  int get total {
    int sub = subTotal;

    if (goProtectType != null) {
      sub += _goProtectCalculation;
    }

    final int withDelivery = (sub - gCoinUsed) + deliveryCharge;

    final withVoucher = withDelivery - voucher;

    return withVoucher;
  }

  int get goProtectPrice => _goProtectCalculation;
  bool get isFromPOS => invoice.startsWith('#GNGM');

  CartModel? goProtectAsCart() {
    if (goProtectType == null) return null;

    final go = CartModel(
      category: Categories.others.title,
      id: 'GO',
      img: Assets.miscGoProtect.path,
      name: 'GO Protect (${goProtectType?.percentage}%)',
      price: _goProtectCalculation,
      quantity: 1,
      isSelected: true,
      inStock: true,
    );

    return go;
  }

  bool get isGoProtected => goProtectType != null;

  List<String> get categories =>
      products.map((e) => e.category).toSet().toList();

  bool containsPhone() =>
      categories.contains(Categories.smartPhone.title) ||
      categories.contains(Categories.preOwned.title);

  bool containsCategory(String category) => categories.contains(category);

  Map<String, dynamic> toMap() {
    return {
      'invoice': invoice,
      'paymentMethod': paymentMethod.title,
      'status': status.title,
      'orderDate': orderDate,
      'address': address.toMap(),
      'user': user.toMap(),
      'items': products.map((e) => e.toMap()).toList(),
      'timeLine': timeLine.map((e) => e.toMap()).toList(),
      'paidAmount': paidAmount,
      'deliveryCharge': deliveryCharge,
      'voucher': voucher,
      'lastMod': lastMod,
      'lastModBy': lastModBy,
      'bkashData': bkashData?.toMap(),
      'gCoinUsed': gCoinUsed,
      'goProtectType': goProtectType?.toMap(),
    };
  }

  OrderModel copyWith({
    String? docID,
    String? invoice,
    AddressModel? address,
    List<CartModel>? products,
    int? paidAmount,
    PaymentMethods? paymentMethod,
    OrderStatus? status,
    DateTime? orderDate,
    UserModel? user,
    List<OrderTimelineModel>? timeLine,
    int? deliveryCharge,
    int? voucher,
    DateTime? lastMod,
    String? lastModBy,
    int? gCoinUsed,
    GoProtectType? Function()? goProtectType,
  }) {
    return OrderModel(
      docID: docID ?? this.docID,
      invoice: invoice ?? this.invoice,
      address: address ?? this.address,
      products: products ?? this.products,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      user: user ?? this.user,
      timeLine: timeLine ?? this.timeLine,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      voucher: voucher ?? this.voucher,
      lastMod: lastMod ?? this.lastMod,
      lastModBy: lastModBy ?? this.lastModBy,
      bkashData: bkashData,
      gCoinUsed: gCoinUsed ?? this.gCoinUsed,
      goProtectType:
          goProtectType != null ? goProtectType() : this.goProtectType,
    );
  }

  String get orderPaymentStatus {
    if (total == paidAmount) return 'Full Paid';

    if (paidAmount > 0 && paidAmount < total) return 'Partial';

    return 'Due';
  }

  int get _goProtectCalculation {
    final productsList = products
        .where((element) =>
            element.category == Categories.smartPhone.title ||
            element.category == Categories.preOwned.title)
        .toList();

    final price = productsList.first.total;
    final goProtect = ((goProtectType!.percentage / 100) * price).round();
    return goProtect;
  }
}
