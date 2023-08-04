class StoragePath {
  static const String product = 'products';
  static const String campaign = 'campaign';
  static const String slider = 'slider';
  static const String employee = 'employee';
  static const String app = 'app';
}

class FirePath {
  static const String address = 'address';
  static const String appConfig = 'inApp';
  static const String appUpdate = 'appUpdate';
  static const String gsheetCred = 'gsheets';
  static const String bkashData = 'bkash';
  static const String campaign = 'campaign';
  static const String carts = 'carts';
  static const String coinHistory = 'coinHistory';
  static const String deliveryInfo = 'charges';
  static const String flash = 'flash';
  static const String orders = 'orders';
  static const String products = 'items';
  static const String realOrderId = 'orderID';
  static const String streamLinks = 'links';
  static const String streamList = 'streaming';
  static const String slider = 'slider';
  static const String users = 'users';
  static const String voucher = 'vouchers';
  static const String wishlist = 'wishlist';

  /// document where all employess data is stored
  static const String employess = 'employess';

  /// collection where employee doc in created
  static const String employee = 'employee';
}

class AuthDefaults {
  static const String defaultPhoto =
      'https://firebasestorage.googleapis.com/v0/b/kry-international-83e6c.appspot.com/o/misc%2Fuser.png?alt=media&token=a6992b77-1dcd-4a03-8735-158c93d0aa66';

  static const String employeePhoto =
      'https://firebasestorage.googleapis.com/v0/b/kry-international-83e6c.appspot.com/o/misc%2Femployee.png?alt=media&token=5d0515e1-895f-4080-8258-e13c200b46f0';
}

class FireUrls {
  static const _base = 'https://console.firebase.google.com/u/4/project';
  static const _server = 'gng-test-server';
  static const _service = 'firestore/data';

  static String fireOrderUrl(String docId) =>
      '$_base/$_server/$_service/~2F${FirePath.orders}~2F$docId';

  static String fireProductUrl(String docId) =>
      '$_base/$_server/$_service/~2F${FirePath.products}~2F$docId';
}
