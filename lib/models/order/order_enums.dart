import 'package:flutter/material.dart';
import 'package:gngm/core/core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum PaymentMethods {
  all,
  bkash,
  nagad,
  cod,
  ssl,
  notSelected;

  factory PaymentMethods.fromString(String type) {
    return type == 'Not Selected'
        ? notSelected
        : values.byName(type.toLowerCase());
  }

  PaymentMethods? get valueFilter => this == all ? null : this;

  String get title {
    final map = <PaymentMethods, String>{
      all: 'All',
      bkash: 'Bkash',
      nagad: 'Nagad',
      cod: 'COD',
      ssl: 'SSL',
      notSelected: 'Not Selected',
    };
    return map[this]!;
  }

  Widget logo(Color color) {
    final map = <PaymentMethods, Widget>{
      all: textWidget('ALL'),
      bkash: imgWidget(Assets.bankBkash.path),
      nagad: imgWidget(Assets.bankNagad.path),
      cod: Icon(MdiIcons.accountCash, color: color),
      ssl: imgWidget(Assets.bankSsl.path),
      notSelected: Icon(Icons.help_rounded, color: color),
    };

    return map[this]!;
  }

  Widget textWidget(String name) {
    return Card(
      child: Text(
        name,
        style: GoogleFonts.quicksand(fontSize: 14),
      ),
    );
  }

  Widget imgWidget(String name) {
    return Image.asset(
      name,
      height: 20,
      width: 20,
      fit: BoxFit.cover,
    );
  }
}

enum OrderStatus {
  all(Icons.apps_rounded),
  pending(Icons.pending_outlined),
  processing(Icons.autorenew),
  picked(Icons.inventory_2_outlined),
  shipped(Icons.local_shipping_outlined),
  delivered(Icons.markunread_mailbox_outlined),
  cancelled(Icons.cancel_outlined),
  duplicate(Icons.content_copy_outlined);

  const OrderStatus(this.icon);
  final IconData icon;

  String get title {
    final map = <OrderStatus, String>{
      all: 'All',
      pending: 'Pending',
      processing: 'Processing',
      picked: 'Picked',
      shipped: 'Shipped',
      delivered: 'Delivered',
      cancelled: 'Cancelled',
      duplicate: 'Duplicate',
    };

    return map[this]!;
  }

  OrderStatus? get valueFilter => this == all ? null : this;

  Color get color {
    final map = <OrderStatus, Color>{
      all: const Color(0xff0078d4),
      pending: const Color(0xfffbc02d),
      processing: const Color(0xfff7630c),
      picked: const Color(0xffb4009e),
      shipped: const Color(0xff00aa86),
      delivered: const Color(0xff107c10),
      cancelled: const Color(0xffe81123),
      duplicate: const Color(0xff970a15),
    };

    return map[this]!;
  }

  String get massage {
    final map = <OrderStatus, String>{
      all: '',
      pending: OrderMassage.pending,
      processing: OrderMassage.processing,
      picked: OrderMassage.picked,
      shipped: OrderMassage.shipped,
      delivered: OrderMassage.delivered,
      cancelled: OrderMassage.cancelled,
      duplicate: OrderMassage.cancelled,
    };

    return map[this]!;
  }

  static List<OrderStatus> get kValue =>
      values.where((element) => element != all).toList();
  factory OrderStatus.fromString(String status) =>
      values.byName(status.toLowerCase());
}

enum GoProtectType {
  fivePercent(5),
  tenPercent(10);

  const GoProtectType(this.percentage);
  final int percentage;

  String toMap() => name;

  factory GoProtectType.fromMap(String type) => values.byName(type);
}

enum SearchTerms {
  invoice(Icons.receipt_rounded),
  phone(Icons.phone_rounded),
  name(Icons.person_rounded);

  String get term {
    final map = <SearchTerms, String>{
      invoice: '#GNG',
      phone: '+8801',
      name: 'name:',
    };

    return map[this]!;
  }

  const SearchTerms(this.icon);
  final IconData icon;
}
