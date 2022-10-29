import 'package:shared_preferences/shared_preferences.dart';

const String selectedQr = "SelectQrCode";

Future<void> setQrCode(bool? qrSelected) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setBool(selectedQr, qrSelected ?? false);
}

Future<bool> getQrCode() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  final result = pref.getBool(selectedQr);
  if (result == null) return false;
  return result;
}
