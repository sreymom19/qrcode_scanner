import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingBloc extends ChangeNotifier {
  TextEditingController printerIpController = TextEditingController();

  void setPrinterOption(String option) {
    setPrinterOption(option);
  }

  void setPrinterIp(String ipAddress) {
    setPrinterIp(ipAddress);
  }

  @override
  void dispose() {
    printerIpController.dispose();
    super.dispose();
  }
}
