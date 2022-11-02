import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:visitor_qr_code_scanner/imagestorbyte.dart';
import 'package:visitor_qr_code_scanner/receipt.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'dart:io';

class PrinterSetup extends StatefulWidget {
  const PrinterSetup({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<PrinterSetup> createState() => _PrinterSetupState();
}

class _PrinterSetupState extends State<PrinterSetup> {
  ScreenshotController screenshotController = ScreenshotController();
  String dir = Directory.current.path;
  @override
  void initState() {
    super.initState();
    // print(dir);
    // setState(() {
    //   Process.run('$dir/images/installerX64/install.exe', [' start '])
    //       .then((ProcessResult results) {
    //     print(results.stdout);
    //   });
    // });
  }

  void testPrint(String printerIp, Uint8List theimageThatComesfr) async {
    print("im inside the test print 2");
    // TODO Don't forget to choose printer's paper size
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: 9100);

    if (res == PosPrintResult.success) {
      // DEMO RECEIPT
      await testReceipt(printer, theimageThatComesfr);
      print(res.msg);
      await Future.delayed(const Duration(seconds: 3), () {
        print("prinnter desconect");
        printer.disconnect();
      });
    }
  }
  

  TextEditingController Printer = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Printer IP"),
      ),
      body: Center(
          child: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: Printer,
                decoration: const InputDecoration(hintText: "printer ip"),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                child: const Text(
                  'print res',
                  style: TextStyle(fontSize: 40),
                ),
                onPressed: () {
                  screenshotController
                      .capture(delay: const Duration(milliseconds: 10))
                      .then((capturedImage) async {
                    theimageThatComesfromThePrinter = capturedImage!;
                    setState(() {
                      theimageThatComesfromThePrinter = capturedImage;
                      testPrint(Printer.text, theimageThatComesfromThePrinter);
                    });
                  }).catchError((onError) {
                    print(onError);
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Screenshot(
                controller: screenshotController,
                child: SizedBox(
                    width: 140,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "محمد نعم 臺灣  ",
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Text("-----------------"),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "(  汉字 )",
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "رقم الطلب",
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                          child: Text("-----------------------"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Expanded(
                              flex: 6,
                              child: Center(
                                child: Text(
                                  "التفاصيل",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "السعر ",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "العدد",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Expanded(
                                    flex: 6,
                                    child: Center(
                                      child: Text(
                                        "臺灣",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        "تجربة عيوني انتة ",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        "Test",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Text("----------"),
                      ],
                    )),
              ),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ],
      )),
    );
  }
}
