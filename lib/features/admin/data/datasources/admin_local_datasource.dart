import 'package:shared_preferences/shared_preferences.dart';

abstract class AdminLocalDatasource {
  Future<bool> isAdminLoggedIn();

  Future<void> setAdminLoggedIn(bool isLoggedIn);

  Future<void> clearAdminSession();
}

class AdminLocalDatasourceImpl implements AdminLocalDatasource {
  final SharedPreferences sharedPreferences;
  static const String adminKey = 'admin_logged_in';

  AdminLocalDatasourceImpl({required this.sharedPreferences});

  @override
  Future<bool> isAdminLoggedIn() async {
    return sharedPreferences.getBool(adminKey) ?? false;
  }

  @override
  Future<void> setAdminLoggedIn(bool isLoggedIn) async {
    await sharedPreferences.setBool(adminKey, isLoggedIn);
  }

  @override
  Future<void> clearAdminSession() async {
    await sharedPreferences.remove(adminKey);
  }
}
