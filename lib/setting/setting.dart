import 'dart:io';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/preference/printer.dart';
import 'package:qr_code_scanner/preference/printer_option_pref.dart';
import 'package:qr_code_scanner/preference/printer_pref.dart';
import 'package:qr_code_scanner/setting/setting_bloc.dart';
import 'package:screenshot/screenshot.dart';

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _bloc,
                    builder: (context, child) => RadioListTile(
                      title: const Text('Network'),
                      value: PrinterOption.wifi,
                      groupValue: _bloc.printerOption,
                      onChanged: (value) => _bloc.selectedPrinterOption(
                        context,
                        value,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 65, right: 20),
                    child: TextField(
                      controller: _bloc.printerIpController,
                      decoration: const InputDecoration(
                        hintText: 'IP Address',
                        hintStyle:
                            TextStyle(color: Colors.black38, fontSize: 15),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        _bloc.savePrinterIp(value);
                        _bloc.toastMsg(context, "Select Wi-Fi Printer");
                      },
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _bloc,
                    builder: (context, child) => RadioListTile(
                      title: const Text('Bluetooth'),
                      value: PrinterOption.bluetooth,
                      groupValue: _bloc.printerOption,
                      onChanged: (value) => _bloc.selectedPrinterOption(
                        context,
                        value,
                      ),
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
                                _bloc.toastMsg(
                                  context,
                                  "Select Bluetooth Printer",
                                );
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
                  onPressed: () => _bloc.downloadFile(),
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

class TimeValue {
  final int _key;
  final String _value;

  TimeValue(this._key, this._value);
}
