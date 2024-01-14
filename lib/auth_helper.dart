import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static final String _keyIsLoggedIn = "isLoggedIn";
  static final String _keyUserType = "userType";

  static Future<void> setIsLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_keyIsLoggedIn, value);
  }

  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    print("getIsLoggedIn: $isLoggedIn");
    return isLoggedIn;
  }

  static Future<void> setUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyUserType, userType);
  }

  static Future<String> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString(_keyUserType) ?? '';
    print("getUserType: $userType");
    return userType;
  }
}
