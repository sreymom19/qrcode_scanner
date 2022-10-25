import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/preference/printer.dart';
import 'package:qr_code_scanner/preference/printer_pref.dart';

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
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
      print("scan result => ${value}");
      if (!mounted) return;
      setState(() => _devices = value);
      if (_devices.isEmpty) setState(() => _deviceMsg = "No Devices!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Printer"),
        backgroundColor: Colors.redAccent,
      ),
      body: _devices.isEmpty
          ? Center(child: Text(_deviceMsg ?? ""))
          : ListView.builder(
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
                  },
                );
              }),
              itemCount: _devices.length,
            ),
    );
  }
}