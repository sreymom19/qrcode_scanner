import 'package:flutter/material.dart';
import 'package:visitor_qr_code_scanner/db_helper.dart';
import 'package:visitor_qr_code_scanner/model/model_db.dart';
import 'package:visitor_qr_code_scanner/printer_page.dart';
import 'package:intl/intl.dart';
import 'package:visitor_qr_code_scanner/printer_setup.dart';

class VisitorPage extends StatefulWidget {
  const VisitorPage({Key? key}) : super(key: key);

  @override
  State<VisitorPage> createState() => _VisitorPageState();
}

class _VisitorPageState extends State<VisitorPage> {
  final dbHelper = DatabaseHelper.instance;
  final List<ModelDB> items = [];

  //list for printer
  List<Map<String, dynamic>> get data => [
        {'title': 'Milk', 'price': 15, 'qty': 2},
        {'title': 'tooth', 'price': 15, 'qty': 2},
        {'title': 'Glass', 'price': 30, 'qty': 5},
        {'title': 'Garden', 'price': 15, 'qty': 2},
        {'title': 'Milk Om', 'price': 15, 'qty': 2},
      ];
  final f = NumberFormat("\$###,###,00", "en_us");

  @override
  void initState() {
    dbHelper.queryAllRows().then((value) {
      setState(() {
        items.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //blue testing
    int total = 0;
    total = data
        .map((e) => e['price'] * e['qty'])
        .reduce((value, element) => value + element);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor'),
      ),
      body: Column(
        children: [
          const Padding(
              padding: EdgeInsets.only(
            top: 20,
          )),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                color: Colors.black,
                width: 0.1,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 20, top: 10),
              width: double.infinity,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: items
                        .map((visitor) => Text(
                              visitor.prefix,
                              style: const TextStyle(fontSize: 20),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: items
                        .map((visitor) => Text(
                              visitor.name,
                              style: const TextStyle(fontSize: 20),
                            ))
                        .toList(),

                    //design your view here
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: items
                        .map((visitor) => Text(
                              visitor.position,
                              style: const TextStyle(fontSize: 20),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: items
                        .map((visitor) => Text(
                              visitor.company,
                              style: const TextStyle(fontSize: 20),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 200,
            height: 50,
            child: TextButton.icon(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    const StadiumBorder()),
                side: MaterialStateProperty.resolveWith<BorderSide>(
                    (Set<MaterialState> states) {
                  final Color color = states.contains(MaterialState.pressed)
                      ? Colors.blue
                      : Colors.red;
                  return BorderSide(color: color, width: 1);
                }),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrinterSetup(
                              title: "Test",
                            )));
              },
              icon: const Icon(Icons.print_rounded),
              label: const Text(
                "Print",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),

          // Test blue next
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (c, i) {
                return ListTile(
                  title: Text(
                    data[i][Title].toString(),
                  ),
                  subtitle:
                      Text("${f.format(data[i]['price'])} x ${data[i]['qty']}"),
                  trailing: Text(
                    f.format(
                      data[i]['price'] * data[i]['qty'],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.grey,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text("Total: ${f.format(total)}"),
                const SizedBox(width: 20),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => PrinterBluetooth(data)));
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
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
