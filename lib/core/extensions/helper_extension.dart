import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

extension IntOperations on int {
  String toCurrency({bool useName = false}) => NumberFormat.currency(
        locale: 'en_BD',
        symbol: useName ? null : '৳',
        name: useName ? 'BDT ' : null,
        decimalDigits: 0,
        customPattern: '${useName ? 'BDT ' : '৳'} ##,##,##,##,###',
      ).format(this);

  String numberFormate() => NumberFormat.currency(
        locale: 'en_BD',
        decimalDigits: 0,
        customPattern: '##,##,##,##,###',
      ).format(this);
}

extension Calculations on int {
  String discountPercent(int discount) =>
      '${((this - discount) / this * 100).round()}%';
}

extension DateTimeFormat on DateTime {
  DateTime get dateOnly {
    final now = DateTime.now();
    final current = DateTime(now.year, now.month, now.day);
    return current;
  }

  String formatDate([String pattern = 'dd-MM-yyyy']) =>
      DateFormat(pattern).format(this);
}

extension StringEx on String {
  int get asInt {
    final replaced = replaceAll(RegExp('[^0-9]'), '');
    return replaced.isEmpty ? 0 : int.parse(replaced);
  }

  double get asDouble => isEmpty ? 0.0 : double.parse(this);

  String showUntil(int end, [int start = 0]) =>
      length >= end ? '${substring(start, end)}...' : this;

  String get toTitleCase {
    List<String> words = split(' ');

    String capitalizedText = ' ';

    for (int i = 0; i < words.length; i++) {
      capitalizedText += words[i][0].toUpperCase() + words[i].substring(1);
      if (i < words.length - 1) {
        capitalizedText += ' ';
      }
    }
    return capitalizedText.trim();
  }

  String ifEmpty([String? emptyText = 'Empty']) =>
      isEmpty ? '$emptyText' : this;

  bool get isEmail {
    final reg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return reg.hasMatch(this);
  }

  bool get isPhone {
    final reg = RegExp(r'(\+8801\d{9})|(01\d{9})');
    return reg.hasMatch(this);
  }
}

extension DocEx on DocumentSnapshot {
  bool containsKey(String key) => (data() as Map).containsKey(key);
}

extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0";
    final units = ["B", "kB", "MB", "GB", "TB"];
    int digitGroups = (log(this) / log(base)).round();
    return "${NumberFormat("#,##0.#").format(this / pow(base, digitGroups))} ${units[digitGroups]}";
  }
}
