import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_scanner/main_bloc.dart';
import 'package:qr_code_scanner/main_form.dart';
import 'package:qr_code_scanner/setting/setting.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
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
  MobileScannerController cameraController = MobileScannerController();

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
    return Scaffold(
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
          // IconButton(
          //   onPressed: () => Navigator.push(context,
          //       MaterialPageRoute(builder: (builder) => PrinterPage())),
          //   icon: const Icon(Icons.print),
          // ),
          // IconButton(
          //   onPressed: () => Navigator.push(context,
          //       MaterialPageRoute(builder: (builder) => VisitorPage())),
          //   icon: const Icon(Icons.apple),
          // ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 28.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          // IconButton(
          //   color: Colors.white,
          //   icon: ValueListenableBuilder(
          //     valueListenable: cameraController.cameraFacingState,
          //     builder: (context, state, child) {
          //       switch (state) {
          //         case CameraFacing.front:
          //           return const Icon(Icons.camera_front);
          //         case CameraFacing.back:
          //           return const Icon(Icons.camera_rear);
          //       }
          //     },
          //   ),
          //   iconSize: 25.0,
          //   onPressed: () => cameraController.switchCamera(),
          // ),
        ],
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.only(top: 40)),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: SizedBox(
                width: 300,
                height: 300,
                child: MobileScanner(
                  allowDuplicates: true,
                  controller: cameraController,
                  onDetect: (barcode, args) {
                    if (barcode.rawValue == null) {
                      debugPrint('Failed to scan Barcode');
                    } else {
                      // cameraController.stop();
                      _bloc.onScan(barcode.rawValue);
                    }
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 200,
                  height: 80,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainForm()));
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    icon: const Icon(
                      Icons.add_box_sharp,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 80,
                  child: TextButton.icon(
                    onPressed: () {
                      _bloc.printInfo(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    icon: const Icon(
                      Icons.qr_code,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Scan',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
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
