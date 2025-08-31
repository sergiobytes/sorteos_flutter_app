import 'package:shared_preferences/shared_preferences.dart';

class AdminPrefs {
  static const _kEmail = 'admin_email';

  static Future<void> saveEmail(String email) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kEmail, email);
  }

  static Future<String?> loadEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kEmail);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kEmail);
  }
}
