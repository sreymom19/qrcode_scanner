import 'dart:convert';

import 'package:charset_converter/charset_converter.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart' as network;
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:qr_code_scanner/model/model_db.dart';
import 'package:qr_code_scanner/preference/printer_ip_pref.dart';
import 'package:qr_code_scanner/preference/printer_option_pref.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'package:qr_code_scanner/preference/qrcode_pref.dart';
import 'db_helper.dart';
import 'preference/printer_pref.dart';

const PosStyles posStyle = PosStyles(
  bold: true,
  height: PosTextSize.size2,
  width: PosTextSize.size2,
);

class MainBloc extends ChangeNotifier {
  late BuildContext context;
  final dbHelper = DatabaseHelper.instance;
  final PrinterBluetoothManager _printerManager = PrinterBluetoothManager();

  final TextEditingController prefixController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  ModelDB? item;
  bool? isChecked = false;

  void init(BuildContext context) async {
    this.context = context;
  }

  void onQrCodeChecked(bool? value) {
    isChecked = value;
    notifyListeners();
  }

  void onScan(String? code) {
    final List<String> result = code!.split("/");
    setTextController(result);
    notifyListeners();
  }

  void setTextController(List<String> result) {
    prefixController.text = result[0];
    nameController.text = result[1];
    companyController.text = result[2];
    positionController.text = result[3];
    typeController.text = result[4];
    emailController.text = result[5];
    phoneController.text = result[6];
  }

  void insertToDB() async {
    await dbHelper.insertQR(item!);
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) return false;
    if (phoneController.text.trim().isEmpty) return false;
    return true;
  }

  void printInfo(BuildContext context) {
    if (_validateForm()) {
      _showLoading();
      item = ModelDB(
        prefix: prefixController.text.trim(),
        name: nameController.text.trim(),
        position: positionController.text.trim(),
        company: companyController.text.trim(),
        type: typeController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      );
      insertToDB();
      getQrCode().then(
        (value) {
          isChecked = value;
          getPrinterOption().then((value) {
            if (value == PrinterOption.bluetooth.name) {
              _bluetoothPrint();
            } else {
              _wifiPrint();
            }
          });
        },
      );
    } else {
      _toastMsg(context, "Please enter information before print");
    }
  }

  void _toastMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showLoading() {
    final alert = AlertDialog(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text("Printing..."),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => alert,
    );
  }

  void _bluetoothPrint() {
    getPrinter().then((value) {
      final device = BluetoothDevice.fromJson(value?.toJson());
      final printer = PrinterBluetooth(device);
      _startPrint(printer, item!);
    });
  }

  void _wifiPrint() async {
    getPrinterIP().then((value) async {
      const PaperSize paper = PaperSize.mm80;
      final profile = await CapabilityProfile.load();
      final printer = network.NetworkPrinter(paper, profile);
      await printer
          .connect(
        value,
        port: 9100,
      )
          .then((value) {
        if (value == network.PosPrintResult.success) {
          testPrintIp(printer);
          Navigator.pop(context);
        }
      });
    });
  }

  void testPrintIp(network.NetworkPrinter printer) {
    printer.text('${item?.prefix}', styles: posStyle);
    printer.text('${item?.name}', styles: posStyle);
    printer.text('${item?.position}', styles: posStyle);
    printer.text('${item?.company}', styles: posStyle);
    if (isChecked == true) {
      printer.qrcode(
        '${item?.prefix}/${item?.name}/${item?.position}/${item?.company}/${item?.type}/${item?.email}/${item?.phone}',
        size: QRSize.Size6,
      );
    }
    printer.feed(1);
    printer.cut();
  }

  void _startPrint(PrinterBluetooth printer, ModelDB data) async {
    _printerManager.selectPrinter(printer);
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    await _printerManager
        .printTicket(
      (await _printTicket(
        paper,
        profile,
        data,
      )),
    )
        .then((value) {
      if (value == PosPrintResult.success) {
        Navigator.pop(context);
      }
    });
  }

  Future<List<int>> _printTicket(
    PaperSize paper,
    CapabilityProfile profile,
    ModelDB data,
  ) async {
    final Generator generator = Generator(paper, profile);
    List<int> bytes = [];

    bytes += generator.text(
      '${data.prefix}: ${data.name}',
      styles: posStyle,
      linesAfter: 1,
    );
    bytes += generator.text(data.position, styles: posStyle, linesAfter: 1);
    bytes += generator.text(data.company, styles: posStyle, linesAfter: 1);

    if (isChecked == true) {
      bytes += generator.qrcode(
        '${data.prefix}/${data.name}/${data.position}/${data.company}/${data.type}/${data.email}/${data.phone}',
        size: QRSize.Size6,
      );
    }

    bytes += generator.feed(1);
    bytes += generator.cut();
    return bytes;
  }

  @override
  void dispose() {
    prefixController.dispose();
    nameController.dispose();
    companyController.dispose();
    positionController.dispose();
    typeController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

class UppercaseTxt extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
