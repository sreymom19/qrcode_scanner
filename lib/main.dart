import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_scanner/main_bloc.dart';
import 'package:qr_code_scanner/model/model_db.dart';
import 'package:qr_code_scanner/setting.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MainBloc _bloc = MainBloc();
  MobileScannerController cameraController = MobileScannerController();

  ModelDB? item;
  final List<ModelDB> items = [];

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
            icon: const Icon(Icons.info_outline),
            iconSize: 25,
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
            iconSize: 25.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 25.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: SizedBox(
                  width: 270,
                  height: 270,
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
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: Column(
                  children: [
                    Container(
                      child: TextFormField(
                        enabled: false,
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 20),
                        controller: _bloc.prefixController,
                        decoration: const InputDecoration(
                          hintText: 'Mr/Ms/Mrs',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      child: TextFormField(
                        enabled: false,
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 20),
                        controller: _bloc.nameController,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      child: TextFormField(
                        enabled: false,
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 20),
                        controller: _bloc.positionController,
                        decoration: const InputDecoration(
                          hintText: 'Position',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      child: TextFormField(
                        enabled: false,
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 20),
                        controller: _bloc.companyController,
                        decoration: const InputDecoration(
                          hintText: 'Company',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Checkbox(
                            value: _bloc.isChecked,
                            onChanged: (bool? value) => _bloc.onQrCodeChecked(
                              value,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'QR Code',
                          style: TextStyle(color: Colors.black54, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    AnimatedBuilder(
                        animation: _bloc,
                        builder: ((context, child) => QrImage(
                              data:
                                  "${_bloc.item?.prefix}/${_bloc.item?.name}/${_bloc.item?.position}/${_bloc.item?.company}/${_bloc.item?.type}/${_bloc.item?.email}/${_bloc.item?.phone}",
                              size: 200,
                            ))),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton.icon(
                onPressed: () {
                  _bloc.printInfo();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                icon: const Icon(
                  Icons.print,
                  color: Colors.white,
                ),
                label: const Text(
                  'Print',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
