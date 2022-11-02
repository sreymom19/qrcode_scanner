import 'package:flutter/material.dart';
import 'package:visitor_qr_code_scanner/main_bloc.dart';
import 'package:visitor_qr_code_scanner/setting/setting.dart';

class MainForm extends StatefulWidget {
  final MainBloc bloc;
  final String? value;
  final Function() screenClosed;

  const MainForm({
    Key? key,
    required this.bloc,
    this.value,
    required this.screenClosed,
  }) : super(key: key);

  @override
  State<MainForm> createState() => _MainFormState();
}

class _MainFormState extends State<MainForm> {

  @override
  void initState() {
    if (widget.value != null) {
      widget.bloc.setTextController(widget.value);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.screenClosed();
        Navigator.pop(context);
        return true;
      },
      child: AnimatedBuilder(
        animation: widget.bloc,
        builder: (context, child) => Scaffold(
          appBar: AppBar(
            title: const Text('Visitor Form'),
            leading: IconButton(
              onPressed: () {
                widget.screenClosed();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_outlined),
            ),
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
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: Column(
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 30)),
                      const Text(
                        'Visitor Information',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        inputFormatters: [UppercaseTxt()],
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 20),
                        controller: widget.bloc.nameController,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        inputFormatters: [UppercaseTxt()],
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 20),
                        controller: widget.bloc.positionController,
                        decoration: const InputDecoration(
                          hintText: 'Position',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        inputFormatters: [UppercaseTxt()],
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 20),
                        controller: widget.bloc.companyController,
                        decoration: const InputDecoration(
                          hintText: 'Company',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        inputFormatters: [UppercaseTxt()],
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 20),
                        controller: widget.bloc.typeController,
                        decoration: const InputDecoration(
                          hintText: 'Type',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 20),
                        controller: widget.bloc.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 20),
                        controller: widget.bloc.phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Mobile',
                          hintStyle:
                              TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: TextButton.icon(
                          onPressed: () {
                            widget.bloc.printInfo(context);
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
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
