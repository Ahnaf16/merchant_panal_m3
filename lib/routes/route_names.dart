import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class RoutesName {
  static const String root = '/';
  static const String login = '/login';
  static const String dash = '/dash';
  static const String products = '/products';
  static String productsDetails(String id) => '/product/$id';
  static const String addProducts = '/add_products';
  static String editProducts(String id) => '/product/edit/$id';
  static const String orders = '/orders';
  static String ordersDetails(String id) => '/order/$id';
  static const String more = '/more';
  static const String campaign = '/campaign';
  static String campaignDetails(String title) {
    final parsedTitle = title.replaceAll(' ', '_');
    return '$campaign/$parsedTitle';
  }

  static const String addCampaign = '$campaign/add';
  static String editCampaign(String title) {
    final parsedTitle = title.replaceAll(' ', '_');
    return '$campaign/edit/$parsedTitle';
  }

  static const String flash = '/flash';
  static const String addFlash = '$flash/add-flash';
  static const String slider = '/slider';
  static const String voucher = '/voucher';
  static const String news = '/news';
  static const String pos = '/pos';
  static const String appVersion = '/version_control';
  static const String delivery = '/delivery_charges';
  static const String employee = '/employee';
  static const String addEmployee = '$employee/add';
  static String editEmployee(String uid) => '$employee/edit/$uid';

  static List<String> panePage(BuildContext context) =>
      Breakpoints.small.isActive(context)
          ? [dash, products, addProducts, orders, more]
          : [
              dash,
              products,
              addProducts,
              orders,
              pos,
              campaign,
              flash,
              voucher,
              slider,
              news,
              more,
            ];
}
