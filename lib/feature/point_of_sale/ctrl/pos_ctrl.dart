import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/feature/auth/provider/auth_provider.dart';
import 'package:merchant_m3/feature/orders/ctrl/google_shit_ctrl.dart';
import 'package:merchant_m3/feature/orders/repo/order_list_repo.dart';
import 'package:merchant_m3/feature/point_of_sale/view/local/edit_product_ctrl.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:nanoid/nanoid.dart';

final posCtrlProvider = StateNotifierProvider.autoDispose
    .family<POSCtrlNotifier, OrderModel, String?>((ref, orderId) {
  return POSCtrlNotifier(orderId, ref).._init();
});

class POSCtrlNotifier extends StateNotifier<OrderModel> {
  POSCtrlNotifier(this._orderId, this._ref) : super(OrderModel.empty);
  final Ref _ref;
  final String? _orderId;

  OrdersRepo get _repo => _ref.read(ordersRepoProvider);

  final customerNameCtrl = TextEditingController();
  final phoneNumberCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final productNameCtrl = TextEditingController();
  final iMEICtrl = TextEditingController();
  final productPriceCtrl = TextEditingController();
  final productQuantityCtrl = TextEditingController(text: '1');
  final deliveryCtrl = TextEditingController();
  final paidAmountCtrl = TextEditingController(text: '0');

  _init() async {
    if (_orderId != null) {
      final orderData = await _repo.fetchOrderWithID(_orderId!);

      orderData.fold(
        (l) => Toaster.showFailure(l),
        (r) => state = r,
      );
      customerNameCtrl.text = state.address.name;
      phoneNumberCtrl.text = state.address.billingNumber;
      addressCtrl.text = state.address.address;
      deliveryCtrl.text = state.deliveryCharge.toString();
      paidAmountCtrl.text = state.paidAmount.toString();
    }
  }

  submitPOS(BuildContext context, bool uploadToSheet) async {
    context.showLoader();

    _applyChanges();
    if (!_validateState.$1) {
      context.showError(_validateState.$2);
      return 0;
    }

    final res = _orderId == null
        ? await _repo.addNewOrder(state)
        : await _repo.updateOrder(state);

    res.fold(
      (l) => context.showError(l.message),
      (r) {
        context.showSuccess(r);
        if (uploadToSheet) addToGoogleSheet(context);
        context.pop;
      },
    );
  }

  refresh() {
    state = OrderModel.empty;
    customerNameCtrl.clear();
    phoneNumberCtrl.clear();
    addressCtrl.clear();
    productNameCtrl.clear();
    productPriceCtrl.clear();
    productQuantityCtrl.clear();
    deliveryCtrl.clear();
    paidAmountCtrl.clear();
  }

  addToGoogleSheet(BuildContext context) async {
    final gSheetCtrl = _ref.read(gSheetCtrlProvider.notifier);
    final res = await gSheetCtrl.addOrderToGSheet(state);

    res.fold(
      (l) => context.showError(l.message),
      (r) => context.showSuccess(r),
    );
  }

  scanBarCode() async {
    final scannedValue = await BarCodeHelper.scan();
    iMEICtrl.text = scannedValue;
  }

  (bool, String) get _validateState {
    if (state.products.isEmpty) {
      return (false, 'No product selected');
    }
    if (customerNameCtrl.text.isEmpty) {
      return (false, 'Enter Customer Name');
    }

    if (phoneNumberCtrl.text.isEmpty) {
      return (false, 'Enter Customer Phone Number');
    }
    if (!phoneNumberCtrl.text.isPhone) {
      return (false, 'Enter Valid Phone Number');
    }
    if (state.address.division.isEmpty) {
      return (false, 'Enter Division');
    }
    if (state.address.district.isEmpty) {
      return (false, 'Enter District');
    }
    if (addressCtrl.text.isEmpty) {
      return (false, 'Enter Address');
    }

    return (true, 'Valid');
  }

  _applyChanges() {
    final isUpdating = _orderId != null;

    final address = state.address.copyWith(
      name: customerNameCtrl.text,
      billingNumber: phoneNumberCtrl.text,
      address: addressCtrl.text,
    );
    final customer = state.user.copyWith(
      uid: getUser?.uid,
      email: getUser?.email,
      phone: getUser?.phoneNumber,
      displayName: getUser?.displayName,
    );

    final newOrderTimelines = [
      OrderTimelineModel(
        status: OrderStatus.pending,
        date: DateTime.now(),
        userName: getUser?.displayName ?? 'noName',
        comment: 'From POS',
      ),
      OrderTimelineModel(
        status: OrderStatus.picked,
        date: DateTime.now(),
        userName: getUser?.displayName ?? 'noName',
        comment: 'From POS',
      ),
    ];
    state = state.copyWith(
      orderDate: isUpdating ? null : DateTime.now(),
      lastMod: DateTime.now(),
      invoice: isUpdating ? null : '#GNGM${customAlphabet('0123456789', 6)}',
      status: isUpdating ? null : OrderStatus.picked,
      address: address,
      user: isUpdating ? null : customer,
      deliveryCharge: deliveryCtrl.text.asInt,
      paidAmount: paidAmountCtrl.text.asInt,
      timeLine: [
        ...state.timeLine,
        if (isUpdating)
          OrderTimelineModel(
            status: state.status,
            date: DateTime.now(),
            userName: getUser?.displayName ?? 'noName',
            comment: 'From POS',
          )
        else
          ...newOrderTimelines,
      ],
    );
  }

  addProductToOrder(ProductModel product) {
    state = state.copyWith(
      products: [...state.products, CartModel.fromProduct(product)],
    );
  }

  removeProductToOrder(int index) {
    final products = state.products;
    products.removeAt(index);
    state = state.copyWith(products: products);
  }

  selectDivision(String division) {
    selectDistrict('');
    return state =
        state.copyWith(address: state.address.copyWith(division: division));
  }

  selectDistrict(String district) => state =
      state.copyWith(address: state.address.copyWith(district: district));

  showEditProductDialog(BuildContext context, CartModel product) async {
    productNameCtrl.text = product.name;
    productPriceCtrl.text = product.price.toString();
    productQuantityCtrl.text = product.quantity.toString();
    iMEICtrl.text = product.imei;
    showDialog(
      context: context,
      builder: (context) =>
          EditProductDialog(product: product, orderId: _orderId),
    );
  }

  submitEditedProduct(CartModel product) {
    final updated = product.copyWith(
      name: productNameCtrl.text,
      price: productPriceCtrl.text.asInt,
      quantity: productQuantityCtrl.text.asInt,
      imei: iMEICtrl.text,
    );

    _insertEditedProduct(updated);
  }

  updateQuantity(CartModel product, bool isUp) {
    int quantity = productQuantityCtrl.text.asInt;
    if (isUp) {
      quantity += 1;
    } else {
      quantity > 1 ? quantity -= 1 : quantity;
    }
    productQuantityCtrl.text = quantity.toString();

    final updated = product.copyWith(quantity: quantity);

    _insertEditedProduct(updated);
  }

  applyGoProtect(GoProtectType? type) {
    state = state.copyWith(goProtectType: () => type);
  }

  clearGoProtect() {
    state = state.copyWith(goProtectType: () => null);
  }

  String? get goProtectError {
    if (state.products.isEmpty) return null;

    final phones = _getPhones();

    if (phones.isEmpty) return 'Only available on Smart Phone.';

    if (phones.length > 1) {
      return 'To use Go Product select only one Smart Phone.';
    }

    final quantity = phones.single.quantity;

    if (quantity > 1) return 'Smart Phone quantity must be no more then One.';

    return null;
  }

  bool get isGoProtectUsable {
    List<CartModel> products = _getPhones();

    if (products.isEmpty) return false;

    if (products.length > 1) return false;

    final quantity = products.single.quantity;

    if (quantity > 1) return false;

    return true;
  }

  applyDeliveryCharge() async {
    final charges = await _calculateDeliveryCharge();
    deliveryCtrl.text = charges.toString();
  }

  Future<DeliveryChargeModel> _fetchDeliveryCharge() async {
    final chargeRef = await FirebaseFirestore.instance
        .collection(FirePath.appConfig)
        .doc(FirePath.deliveryInfo)
        .get();

    final charges = DeliveryChargeModel.fromDoc(chargeRef);
    return charges;
  }

  Future<int> _calculateDeliveryCharge() async {
    if (state.products.isEmpty) {
      Toaster.show('No product selected');
      return 0;
    }

    final charges = await _fetchDeliveryCharge();

    bool containsPhone = state.containsPhone();
    final isDhaka = state.address.district == 'Dhaka';

    if (!charges.haveDelivery) return 0;
    if (isDhaka && containsPhone) return charges.phnInside;
    if (!isDhaka && containsPhone) return charges.phnOutside;
    if (isDhaka && !containsPhone) return charges.accessoryInside;
    if (!isDhaka && !containsPhone) return charges.accessoryOutside;

    return charges.phnOutside;
  }

  List<CartModel> _getPhones() {
    final products = state.products
        .where((element) =>
            element.category == Categories.smartPhone.title ||
            element.category == Categories.preOwned.title)
        .toList();
    return products;
  }

  _insertEditedProduct(CartModel product) {
    final products = state.products;
    final index = products.indexWhere((element) => element.id == product.id);

    state = state.copyWith(
      products: [
        ...state.products.sublist(0, index),
        product,
        ...state.products.sublist(index + 1),
      ],
    );
  }

  @override
  void dispose() {
    customerNameCtrl.dispose();
    phoneNumberCtrl.dispose();
    addressCtrl.dispose();
    productNameCtrl.dispose();
    productPriceCtrl.dispose();
    productQuantityCtrl.dispose();
    deliveryCtrl.dispose();
    paidAmountCtrl.dispose();
    super.dispose();
  }
}
