import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/preference/printer_ip_pref_dart';
import 'package:qr_code_scanner/preference/printer_option_pref.dart';

class SettingBloc extends ChangeNotifier {
  TextEditingController printerIpController = TextEditingController();
  PrinterOption? printerOption = PrinterOption.wifi;

  void init() {
    getPrinterOption().then((value) {
      if (value == PrinterOption.bluetooth.name) {
        printerOption = PrinterOption.bluetooth;
      } else {
        printerOption = PrinterOption.wifi;
        getPrinterIpAddress();
      }
    });
    notifyListeners();
  }

  void selectedPrinterOption(BuildContext context, PrinterOption? option) {
    setPrinterOption(option);
    printerOption = option;
    if (printerOption == PrinterOption.wifi) getPrinterIpAddress();
    notifyListeners();
  }

  void getPrinterIpAddress() {
    getPrinterIP().then((value) => printerIpController.text = value);
  }

  void savePrinterIp(String ipAddress) {
    setPrinterIP(ipAddress);
  }

  void toastMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    printerIpController.dispose();
    super.dispose();
  }
}
