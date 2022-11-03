import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart' as network;
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:visitor_qr_code_scanner/model/model_db.dart';
import 'package:visitor_qr_code_scanner/preference/printer_ip_pref.dart';
import 'package:visitor_qr_code_scanner/preference/printer_option_pref.dart';
import 'package:visitor_qr_code_scanner/preference/qrcode_pref.dart';
import 'package:visitor_qr_code_scanner/preference/seperate_pref.dart';

import 'db_helper.dart';
import 'preference/printer_pref.dart';

const PosStyles posStyle = PosStyles(
  bold: true,
  align: PosAlign.center,
  height: PosTextSize.size3,
  width: PosTextSize.size3,
  fontType: PosFontType.fontA,
);

class MainBloc extends ChangeNotifier {
  late BuildContext context;
  final dbHelper = DatabaseHelper.instance;
  final PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  MobileScannerController cameraController = MobileScannerController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  ModelDB? item;
  bool? isChecked = false;

  //List<String> prefixes = ["Mr", "Ms", "Mrs"];
  //String? valuePre;

  void init(BuildContext context) async {
    this.context = context;
  }

  void onQrCodeChecked(bool? value) {
    isChecked = value;
    notifyListeners();
  }

  void setTextController(String? code) {
    getSeparate().then((value) {
      final List<String>? result = code?.split(value);
      nameController.text = result?.elementAt(0) ?? "";
      companyController.text = result?.elementAt(1) ?? "";
      positionController.text = result?.elementAt(2) ?? "";
      typeController.text = result?.elementAt(3) ?? "";
      emailController.text = result?.elementAt(4) ?? "";
      phoneController.text = result!.length > 6 ? result[6] : result[5];
    });
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
          print("isQrPrinte => $value");
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
      clear();
      toastMsg(context, "Print Successfully");
    } else {
      toastMsg(context, "Please enter information before print");
    }
  }

  void clear() {
    nameController.clear();
    positionController.clear();
    companyController.clear();
    typeController.clear();
    emailController.clear();
    phoneController.clear();
  }

  void toastMsg(BuildContext context, String msg) {
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
      await printer.connect(value, port: 9100).then((value) {
        if (value == network.PosPrintResult.success) {
          testPrintIp(printer);
          Navigator.pop(context);
        }
      });
    });
  }

  void testPrintIp(network.NetworkPrinter printer) {
    try {
      printer.text(_limitChar(item?.name), styles: posStyle);
      printer.text(_limitChar(item?.position), styles: posStyle);
      printer.text(_limitChar(item?.company), styles: posStyle);
      if (isChecked == true) {
        printer.qrcode(
          '${item?.name}${item?.position}${item?.company}${item?.type}${item?.email}${item?.phone}',
          size: QRSize.Size5,
        );
      }
      printer.text('TRADE VISITOR', styles: posStyle);
      printer.feed(1);
      printer.cut();
      printer.disconnect();
    } catch (e) {
      print("testPrintIp: $e");
    }
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

    bytes += generator.text(_limitChar(data.name), styles: posStyle);
    bytes += generator.text(_limitChar(data.position), styles: posStyle);
    bytes += generator.text(_limitChar(data.company), styles: posStyle);
    if (isChecked == true) {
      bytes += generator.qrcode(
        '${data.name}${data.position}${data.company}${data.type}${data.email}${data.phone}',
        size: QRSize.Size5,
      );
    }
    bytes += generator.text(
      "TRADE VISITOR",
      styles: posStyle,
    );
    bytes += generator.feed(1);
    bytes += generator.cut();
    return bytes;
  }

  String _limitChar(String? value) {
    final result = value!.length > 15 ? value.substring(0, 15) : value;
    print("limtChar => $result");
    return result;
  }

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    positionController.dispose();
    typeController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<bool> isValidQrCode(String? code) async {
    final value = await getSeparate();
    if (code?.contains(value) == true ) return true;
    return false;
  }
}

class UppercaseTxt extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
