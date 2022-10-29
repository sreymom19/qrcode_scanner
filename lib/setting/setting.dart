import 'dart:io';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/preference/printer_option_pref.dart';
import 'package:qr_code_scanner/preference/qrcode_pref.dart';
import 'package:qr_code_scanner/setting/setting_bloc.dart';
import 'package:screenshot/screenshot.dart';
import '../main_bloc.dart';
import '../preference/printer.dart';
import '../preference/printer_pref.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? printerType;
  ScreenshotController screenshotController = ScreenshotController();
  String dir = Directory.current.path;

  final _bloc = SettingBloc();
  final PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String? _deviceMsg;

  @override
  void initState() {
    _bloc.init();
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(top: 20)),
            const Text(
              "Select Printer Option:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _bloc,
                      builder: (context, child) => Radio(
                        value: PrinterOption.wifi,
                        groupValue: _bloc.printerOption,
                        onChanged: (value) => _bloc.selectedPrinterOption(
                          context,
                          value,
                        ),
                      ),
                    ),
                    const Text('Network'),
                  ],
                ),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _bloc,
                      builder: (context, child) => Radio(
                        value: PrinterOption.bluetooth,
                        groupValue: _bloc.printerOption,
                        onChanged: (value) => _bloc.selectedPrinterOption(
                          context,
                          value,
                        ),
                      ),
                    ),
                    const Text('Bluetooth'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Setup Printer Option:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedBuilder(
              animation: _bloc,
              builder: (context, child) => _bloc.printerOption ==
                      PrinterOption.wifi
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _bloc.printerIpController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Printer IP Address',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          _bloc.savePrinterIp(value);
                          _bloc.toastMsg(context, "Select Wi-Fi Printer");
                        },
                      ),
                    )
                  : _devices.isEmpty
                      ? Center(
                          child: Text(_deviceMsg ?? ""),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: ((context, index) {
                            return Column(
                              children: [
                                ListTile(
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
                                    _bloc.toastMsg(
                                      context,
                                      "Select Bluetooth Printer",
                                    );
                                  },
                                ),
                                const Divider(
                                  height: 0.5,
                                  color: Colors.grey,
                                )
                              ],
                            );
                          }),
                          itemCount: _devices.length,
                        ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Select QR Code',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: AnimatedBuilder(
                    animation: _bloc,
                    builder: (context, child) => Checkbox(
                      value: _bloc.isShouldQrCodePrint,
                      onChanged: (bool? value) =>
                          _bloc.onShouldQrCodePrintChecked(
                        value,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'QR Code',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
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
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _bloc.getVisitors(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Download File',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showMyDialog(context);
                    },
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
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure to clear data?'),
                Text('Click No to cancel, Yes to clear data'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _bloc.clearData();
                Navigator.of(context).pop();
                _bloc.toastMsg(context, "Clear Successfully");
              },
            ),
          ],
        );
      },
    );
  }
}
