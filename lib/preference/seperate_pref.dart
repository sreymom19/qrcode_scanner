import 'package:shared_preferences/shared_preferences.dart';

const String separateDevide = "separate";

Future<void> setSeparate(String separate) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setString(separateDevide, separate);
}

Future<String> getSeparate() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  final result = pref.getString(separateDevide);
  if (result == null) return "/";
  return result;
}
