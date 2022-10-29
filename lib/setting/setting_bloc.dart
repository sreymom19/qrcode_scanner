import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_scanner/db_helper.dart';
import 'package:qr_code_scanner/model/model_db.dart';
import 'package:qr_code_scanner/preference/printer_option_pref.dart';
import 'package:qr_code_scanner/preference/qrcode_pref.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../preference/printer_ip_pref.dart';

class SettingBloc extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  TextEditingController printerIpController = TextEditingController();
  PrinterOption? printerOption = PrinterOption.wifi;
  bool? isShouldQrCodePrint = false;

  void init() {
    getQrCode().then((value) {
      isShouldQrCodePrint = value;
      getPrinterOption().then((value) {
        if (value == PrinterOption.bluetooth.name) {
          printerOption = PrinterOption.bluetooth;
        } else {
          printerOption = PrinterOption.wifi;
          getPrinterIpAddress();
        }
      });
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

  void onShouldQrCodePrintChecked(bool? value) {
    isShouldQrCodePrint = value;
    setQrCode(value);
    notifyListeners();
  }

  void toastMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> exportFile(List<ModelDB> data) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    /// Header
    final Range headerRange = sheet.getRangeByName("A1:H1");
    headerRange.merge();
    headerRange.cellStyle.fontSize = 12;
    headerRange.cellStyle.hAlign = HAlignType.center;
    headerRange.cellStyle.vAlign = VAlignType.center;
    headerRange.cellStyle.bold = true;
    headerRange.autoFit();
    headerRange.setText("Visitor Data");

    /// Style of column
    final Range columnRange = sheet.getRangeByName("A2:F2");
    columnRange.cellStyle.fontSize = 11;
    columnRange.cellStyle.hAlign = HAlignType.center;
    columnRange.cellStyle.vAlign = VAlignType.center;
    columnRange.cellStyle.bold = true;

    /// Set column name
    sheet.getRangeByName("A2").setText("ID");
    sheet.getRangeByName("B2").setText("Prefix");
    sheet.getRangeByName("C2").setText("Name");
    sheet.getRangeByName("D2").setText("Company");
    sheet.getRangeByName("E2").setText("Position");
    sheet.getRangeByName("F2").setText("Type");
    sheet.getRangeByName("G2").setText("Email");
    sheet.getRangeByName("H2").setText("Phone");

    int rowIndex = 3;

    for (int index = 0; index < data.length; index++) {
      index == 0 ? rowIndex = rowIndex : rowIndex = rowIndex + 1;

      /// Column of ID
      sheet.getRangeByName("A$rowIndex").setText("${index + 1}");
      sheet.getRangeByName("A$rowIndex").cellStyle.vAlign = VAlignType.center;
      sheet.getRangeByName("A$rowIndex").cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName("A$rowIndex").autoFit();

      /// Column of Name
      _bindDataToColumn(sheet, "B$rowIndex", data[index].prefix);

      /// Column of Name
      _bindDataToColumn(sheet, "C$rowIndex", data[index].name);

      /// Column of Company
      _bindDataToColumn(sheet, "D$rowIndex", data[index].company);

      /// Column of Position
      _bindDataToColumn(sheet, "E$rowIndex", data[index].position);

      /// Column of Type
      _bindDataToColumn(sheet, "F$rowIndex", data[index].type);

      /// Column of Email
      _bindDataToColumn(sheet, "G$rowIndex", data[index].email);

      /// Column of Phone
      _bindDataToColumn(sheet, "H$rowIndex", data[index].phone);
    }
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    final path = (await getApplicationSupportDirectory()).path;
    final String fileName = "$path/Visitor.xlsx";
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    _shareFile(fileName);
  }

  Future<void> _shareFile(String fileName) async {
    await Share.shareFiles([fileName]);
  }

  void _bindDataToColumn(Worksheet sheet, String column, String data) {
    final nameColumn = sheet.getRangeByName(column);
    nameColumn.setText(data);
    nameColumn.cellStyle.vAlign = VAlignType.center;
    nameColumn.cellStyle.hAlign = HAlignType.right;
    nameColumn.autoFit();
  }

  void getVisitors(BuildContext context) async {
    await _db.queryAllRows().then((value) {
      if (value.isNotEmpty) {
        exportFile(value);
      } else {
        toastMsg(context, "Don't have data avialble");
      }
    });
  }

  void clearData() {
    _db.delete();
  }

  @override
  void dispose() {
    printerIpController.dispose();
    super.dispose();
  }
}
