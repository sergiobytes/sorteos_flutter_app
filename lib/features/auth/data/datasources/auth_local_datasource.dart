import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDatasource {
  Future<bool> isAdmin();
  Future<void> setAdminStatus(bool isAdmin);
  Future<void> clearAdminStatus();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferences sharedPreferences;
  static const String adminKey = 'admin_logged_in';

  AuthLocalDatasourceImpl({required this.sharedPreferences});

  @override
  Future<bool> isAdmin() async {
    return sharedPreferences.getBool(adminKey) ?? false;
  }

  @override
  Future<void> setAdminStatus(bool isAdmin) async {
    await sharedPreferences.setBool(adminKey, isAdmin);
  }

  @override
  Future<void> clearAdminStatus() async {
    await sharedPreferences.remove(adminKey);
  }
}
