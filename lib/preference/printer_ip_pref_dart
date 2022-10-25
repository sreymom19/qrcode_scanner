import 'package:shared_preferences/shared_preferences.dart';

const String prefPrinterIp = "PrinterIpPref";

Future<void> setPrinterIP(String ipAddress) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setString(prefPrinterIp, ipAddress);
}

Future<String> getPrinterIP() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  final ipAddress = pref.getString(prefPrinterIp);
  if (ipAddress == null) return "";
  return ipAddress;
}
