import 'dart:convert';

import 'package:visitor_qr_code_scanner/preference/printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String prefPrinter = "PrinterPref";

Future<void> selectedPrinter(Printer printer) async {
  String jsonAccountant = jsonEncode(printer.toJson());
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setString(prefPrinter, jsonAccountant);
}

Future<Printer?> getPrinter() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  var accountantString = pref.getString(prefPrinter);
  if (accountantString != null) {
    Map<String, dynamic> map = jsonDecode(accountantString.toString());
    return Printer.fromMap(map);
  } else {
    return null;
  }
}

