import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gngm/core/core.dart';
import 'package:url_launcher/url_launcher_string.dart';

String _prettyJSON(response) {
  final encoder = JsonEncoder.withIndent("  ", (object) => object.toString());
  return encoder.convert(response);
}

logJSON(response, [String name = '']) => log(_prettyJSON(response), name: name);

class Toaster {
  static show(String message) {
    Fluttertoast.showToast(
      msg: message,
      timeInSecForIosWeb: 3,
      webBgColor: '#312624',
      webPosition: 'center',
    );
  }

  static showFailure(Failure failure) {
    Fluttertoast.showToast(
      msg: failure.message,
      timeInSecForIosWeb: 5,
      webBgColor: "#312624",
      webPosition: 'center',
    );
  }

  static remove() => Fluttertoast.cancel();
}

class ClipBoardAPI {
  static copy(String text) {
    Clipboard.setData(ClipboardData(text: text)).whenComplete(
      () => Toaster.show('Copied'),
    );
  }
}

class URLHelper {
  static goTo(String url) async {
    final canLunch = await canLaunchUrlString(url);
    if (canLunch) {
      await launchUrl(Uri.parse(url));
    } else {
      Toaster.show('Not valid URL');
    }
  }

  static call(String number) async {
    if (number.isPhone) {
      final parsed = number.startsWith('+88') ? number : '+88$number';
      await launchUrl(
        Uri(scheme: "tel", path: parsed),
      );
    } else {
      Toaster.show('Phone number is not valid');
    }
  }

  static massage(String number) async {
    if (number.isPhone) {
      final parsed = number.startsWith('+88') ? number : '+88$number';
      try {
        launchUrl(
          Uri(
            scheme: "sms",
            path: "+88$parsed",
            queryParameters: <String, String>{
              'body': Uri.encodeComponent(''),
            },
          ),
        );
      } on Exception catch (e) {
        log(e.toString());
      }
    } else {
      Toaster.show('Phone number is not valid');
    }
  }
}

class BarCodeHelper {
  static Future<String> scan() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#f44336',
        'Close',
        false,
        ScanMode.BARCODE,
      );
      return barcodeScanRes;
    } on Exception catch (e) {
      Toaster.show(e.toString());
      return '';
    }
  }
}
