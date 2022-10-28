import 'package:shared_preferences/shared_preferences.dart';

const String prefPrinterOption = "PrinterOptionPref";

Future<void> setPrinterOption(PrinterOption? option) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setString(
    prefPrinterOption,
    option?.name ?? PrinterOption.bluetooth.name,
  );
}

Future<String> getPrinterOption() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  final option = pref.getString(prefPrinterOption);
  if (option == null) return PrinterOption.bluetooth.name;
  return option;
}

enum PrinterOption { bluetooth, wifi }

