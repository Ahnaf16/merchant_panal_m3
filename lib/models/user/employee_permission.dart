import 'package:flutter/material.dart';
import 'package:merchant_m3/core/core.dart';
import 'package:merchant_m3/models/models.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum EPermissions {
  productAdd,
  productUpdate,
  productDelete,
  ordersView,
  orderUpdate,
  orderToPOS,
  orderDelete,
  campaignAdd,
  campaignDelete,
  flashAdd,
  flashDelete,
  sliderAdd,
  sliderDelete,
  pointOfSale,
  deliveryCharge,
  employeeManage,
  permissionManage,
  firestoreAccess;

  factory EPermissions.fromMap(String name) => values.byName(name);

  String get title => name.toTitleCase;

  String get subtitle => switch (this) {
        productAdd => 'Can Add Products Details',
        productUpdate => 'Can Update Products Details',
        productDelete => 'Can Delete Products',
        ordersView => 'Can View Customer Orders',
        orderUpdate => 'Can Update Customer Orders',
        orderToPOS => 'Can Move order to POS and Update',
        orderDelete => 'Can Delete Customer Orders',
        campaignAdd => 'Can Add Campaigns',
        campaignDelete => 'Can Delete Campaign',
        flashAdd => 'Can Add Flash Sale',
        flashDelete => 'Can Delete Flash sale',
        sliderAdd => 'Can Add Slider Image',
        sliderDelete => 'Can Delete Slider Image',
        pointOfSale => 'Can Use Point of Sale',
        employeeManage => 'Can Manage Employee',
        deliveryCharge => 'Can Change delivery charge',
        firestoreAccess => 'Can access Firebase Firestore',
        permissionManage => 'Can manage Employee Permission',
      };

  IconData get icon => switch (this) {
        productAdd => Icons.add_rounded,
        productUpdate => Icons.update_rounded,
        productDelete => Icons.delete_rounded,
        ordersView => Icons.shopping_bag_rounded,
        orderUpdate => Icons.update_rounded,
        orderToPOS => Icons.point_of_sale_rounded,
        orderDelete => Icons.delete_rounded,
        campaignAdd => Icons.campaign_rounded,
        campaignDelete => Icons.delete_rounded,
        flashAdd => Icons.flash_on_rounded,
        flashDelete => Icons.delete_rounded,
        sliderAdd => Icons.image_rounded,
        sliderDelete => Icons.delete_rounded,
        pointOfSale => Icons.point_of_sale_rounded,
        employeeManage => Icons.manage_accounts_rounded,
        firestoreAccess => MdiIcons.firebase,
        deliveryCharge => Icons.local_shipping_rounded,
        permissionManage => Icons.shield_rounded,
      };

  bool canDo(EmployeeModel? employee) => employee?.can(this) ?? false;

  static showToast() => Toaster.show('NO ACCESS !!');
}
