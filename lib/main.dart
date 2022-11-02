import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:visitor_qr_code_scanner/main_bloc.dart';
import 'package:visitor_qr_code_scanner/main_form.dart';
import 'package:visitor_qr_code_scanner/setting/setting.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Escan Ticket',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MainBloc _bloc = MainBloc();

  final MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  @override
  void initState() {
    _bloc.init(context);
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bloc,
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Mobile Scanner'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              iconSize: 28,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(
                'images/epenh_logo.png',
                width: 200,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Scan QR Code'),
                    const SizedBox(height: 10),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: MobileScanner(
                            allowDuplicates: false,
                            controller: cameraController,
                            onDetect: _foundBarcode,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _bloc.clear();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainForm(
                            bloc: _bloc,
                            screenClosed: _screenWasClosed,
                          )),
                );
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: MediaQuery.of(context).size.width,
                color: Colors.blue,
                child: const Text(
                  "Add New Visitor Manual",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _foundBarcode(Barcode barcode, MobileScannerArguments? arguments) {
    debugPrint("Barcode found! ${barcode.rawValue}");
    if (barcode.rawValue?.contains(";") == true) {
      if (!_screenOpened) {
        final String code = barcode.rawValue ?? "----";
        _screenOpened = true;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainForm(
              bloc: _bloc,
              screenClosed: _screenWasClosed,
              value: code,
            ),
          ),
        );
      }
    } else {
      _bloc.toastMsg(context, "Invalid QR Code");
    }
  }

  void _screenWasClosed() {
    _screenOpened = false;
  }
}
