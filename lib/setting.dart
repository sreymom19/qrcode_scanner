import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:qr_code_scanner/imagestorbyte.dart';
import 'package:qr_code_scanner/preference/printer.dart';
import 'package:qr_code_scanner/preference/printer_option_pref.dart';
import 'package:qr_code_scanner/preference/printer_pref.dart';
import 'package:qr_code_scanner/receipt.dart';
import 'package:qr_code_scanner/setting_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'dart:io';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? printerType;
  ScreenshotController screenshotController = ScreenshotController();
  String dir = Directory.current.path;

  final PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String? _deviceMsg;

  @override
  void initState() {
    initPrinter();
    super.initState();
  }

  Future<void> initPrinter() async {
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.locationWhenInUse.request();
    _printerManager.startScan(const Duration(seconds: 2));
    _printerManager.scanResults.listen((value) {
      if (!mounted) return;
      setState(() => _devices = value);
      if (_devices.isEmpty) setState(() => _deviceMsg = "No Devices!");
    });
  }

  // void testPrint(String printerIp, Uint8List theimageThatComesfr) async {
  //   print("im inside the test print 2");
  //   // TODO Don't forget to choose printer's paper size
  //   const PaperSize paper = PaperSize.mm80;
  //   final profile = await CapabilityProfile.load();
  //   final printer = NetworkPrinter(paper, profile);

  //   final PosPrintResult res = await printer.connect(printerIp, port: 9100);

  //   if (res == PosPrintResult.success) {
  //     // DEMO RECEIPT
  //     await testReceipt(printer, theimageThatComesfr);
  //     print(res.msg);
  //     await Future.delayed(const Duration(seconds: 3), () {
  //       print("prinnter desconect");
  //       printer.disconnect();
  //     });
  //   }
  // }

  // void printNetwork(Function() onPrint) {
  //   screenshotController
  //       .capture(delay: const Duration(milliseconds: 10))
  //       .then((capturedImage) async {
  //     theimageThatComesfromThePrinter = capturedImage!;
  //     setState(() {
  //       theimageThatComesfromThePrinter = capturedImage;
  //       testPrint(Printerprint.text, theimageThatComesfromThePrinter);
  //     });
  //   }).catchError((onError) {
  //     print(onError);
  //   });
  // }

  final _bloc = SettingBloc();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('Network'),
                    value: "Network",
                    groupValue: printerType,
                    onChanged: (value) =>
                        _bloc.setPrinterOption(PrinterOption.wifi.name),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 65, right: 20),
                    child: TextField(
                      controller: _bloc.printerIpController,
                      decoration: const InputDecoration(
                        hintText: 'IP Address',
                        hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) => _bloc.setPrinterIp(value),
                    ),
                  ),
                  RadioListTile(
                    title: const Text('Bluetooth'),
                    value: "Bluetooth",
                    groupValue: printerType,
                    onChanged: (value) => _bloc.setPrinterOption(
                      PrinterOption.bluetooth.name,
                    ),
                  ),
                  _devices.isEmpty
                      ? Center(
                          child: Text(_deviceMsg ?? ""),
                        )
                      : ListView.builder(
                        shrinkWrap: true,
                          itemBuilder: ((context, index) {
                            return ListTile(
                              leading: const Icon(Icons.print),
                              title: Text(_devices[index].name ?? ''),
                              subtitle: Text(_devices[index].address ?? ''),
                              onTap: () {
                                final printer = Printer(
                                  name: _devices[index].name,
                                  address: _devices[index].address,
                                  type: _devices[index].type,
                                );
                                selectedPrinter(printer);
                              },
                            );
                          }),
                          itemCount: _devices.length,
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            height: 40,
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Text(
              'Data Store',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Download File',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Clear Data',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
