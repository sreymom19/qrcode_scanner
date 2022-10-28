import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart' as network;
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:qr_code_scanner/model/model_db.dart';
import 'package:qr_code_scanner/preference/printer_ip_pref.dart';
import 'package:qr_code_scanner/preference/printer_option_pref.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'db_helper.dart';
import 'preference/printer_pref.dart';

class MainBloc extends ChangeNotifier {
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

  void onQrCodeChecked(bool? value) {
    isChecked = value;
    notifyListeners();
  }

  void onScan(String? code) {
    final List<String> result = code!.split("/");
    item = ModelDB(
      prefix: result[0],
      name: result[1],
      position: result[2],
      company: result[3],
      type: result[4],
      email: result[5],
      phone: result.length > 6 ? result[6] : result[5],
    );
    setTextController();
    notifyListeners();
  }

  void setTextController() {
    prefixController.text = item?.prefix ?? "";
    nameController.text = item?.name ?? "";
    companyController.text = item?.company ?? "";
    positionController.text = item?.position ?? "";
    typeController.text = item?.type ?? "";
    emailController.text = item?.email ?? "";
    phoneController.text = item?.phone ?? "";
  }

  void insertToDB() async {
    await dbHelper.insertQR(item!);
  }

  void printInfo() {
    insertToDB();
    getPrinterOption().then((value) {
      if (value == PrinterOption.bluetooth.name) {
        _bluetoothPrint();
      } else {
        _wifiPrint();
      }
    });
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
      print("value => $value");
      const PaperSize paper = PaperSize.mm80;
      final profile = await CapabilityProfile.load();
      final printer = network.NetworkPrinter(paper, profile);

      final network.PosPrintResult result =
          await printer.connect(value, port: 9100);
      if (result == network.PosPrintResult.success) {
        testPrintIp(printer);
      }
    });
  }

  void testPrintIp(network.NetworkPrinter printer) {
    // printer.text(
    //     'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    // printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
    //     styles: const PosStyles(codeTable: 'CP1252'));
    // printer.text('Special 2: blåbærgrød',
    //     styles: const PosStyles(codeTable: 'CP1252'));

    // printer.text('Bold text', styles: const PosStyles(bold: true));
    // printer.text('Reverse text', styles: const PosStyles(reverse: true));
    // printer.text('Underlined text',
    //     styles: const PosStyles(underline: true), linesAfter: 1);
    // printer.text('Align left', styles: const PosStyles(align: PosAlign.left));
    // printer.text('Align center',
    //     styles: const PosStyles(align: PosAlign.center));
    // printer.text('Align right',
    //     styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    // printer.text('Text size 200%',
    //     styles: const PosStyles(
    //       height: PosTextSize.size2,
    //       width: PosTextSize.size2,
    //     ));
    printer.text(
      '${item?.prefix}',
      styles: const PosStyles(
          bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
    );
    printer.text(
      '${item?.name}',
      styles: const PosStyles(
          bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
    );
    printer.text(
      '${item?.position}',
      styles: const PosStyles(
          bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
    );
    printer.text(
      '${item?.company}',
      styles: const PosStyles(
          bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
    );
    if (isChecked == true) {
      printer.qrcode(
          '${item?.prefix}/${item?.name}/${item?.position}/${item?.company}/${item?.type}/${item?.email}/${item?.phone}',
          size: QRSize.Size6);
    }

    printer.feed(2);
    printer.cut();
  }

  void _startPrint(PrinterBluetooth printer, ModelDB data) async {
    _printerManager.selectPrinter(printer);
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final res = await _printerManager.printTicket(
      (await _printTicket(paper, profile, data)),
    );

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(res.msg),
    // ));
  }

  Future<List<int>> _printTicket(
    PaperSize paper,
    CapabilityProfile profile,
    ModelDB data,
  ) async {
    final Generator generator = Generator(paper, profile);
    List<int> bytes = [];

    //bytes += generator.text(
    //    'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    // bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
    //     styles: PosStyles(codeTable: PosCodeTable.westEur));
    // bytes += generator.text('Special 2: blåbærgrød',
    //     styles: PosStyles(codeTable: PosCodeTable.westEur));

    bytes += generator.text(
      '${data.prefix}: ${data.name}',
      styles: const PosStyles(
        bold: true,
        align: PosAlign.left,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );
    // bytes += generator.text(data.name, styles: PosStyles(bold: true));
    bytes += generator.text(
      data.position,
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );
    bytes += generator.text(data.company,
        styles: const PosStyles(
          align: PosAlign.left,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    if (isChecked == true) {
      bytes += generator.qrcode(
        '${data.prefix}/${data.name}/${data.position}/${data.company}/${data.type}/${data.email}/${data.phone}',
        size: QRSize.Size6,
      );
    }

    // bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
    // bytes += generator.text('Underlined text',
    //     styles: PosStyles(underline: true), linesAfter: 1);
    // bytes +=
    //     generator.text('Align left', styles: PosStyles(align: PosAlign.left));
    // bytes += generator.text('Align center',
    //     styles: PosStyles(align: PosAlign.center));
    // bytes += generator.text('Align right',
    //     styles: PosStyles(align: PosAlign.right), linesAfter: 1);
    //
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'col3',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: 'col6',
    //     width: 6,
    //     styles: PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: 'col3',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //]);

    // bytes += generator.text('Text size 200%',
    //     styles: PosStyles(
    //       height: PosTextSize.size2,
    //       width: PosTextSize.size2,
    //     ));

    // Print image
    // final ByteData data = await rootBundle.load('assets/logo.png');
    // final Uint8List buf = data.buffer.asUint8List();
    //final Image image = decodeImage(buf)!;
    // bytes += generator.image(image);
    // Print image using alternative commands
    // bytes += generator.imageRaster(image);
    // bytes += generator.imageRaster(image, imageFn: PosImageFn.graphics);

    // Print barcode
    // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    // bytes += generator.barcode(Barcode.upcA(barData));

    // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
    // bytes += generator.text(
    //   'hello ! 中文字 # world @ éphémère &',
    //   styles: PosStyles(codeTable: PosCodeTable.westEur),
    //   containsChinese: true,
    // );

    bytes += generator.feed(2);

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
