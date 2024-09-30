import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsData {
  static const String S3FAkshayaData = "srikarapp";
  static const String userIdKey = "user_id";
  static const String categoriesKey = "categories";
  static const String bankDetailsKey = "bank_details";

  static SharedPreferences? _sharedPrefs; // Make it nullable

  static Future<SharedPreferences?> get _instance async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
    return _sharedPrefs;
  }

  static Future<void> saveUserId(String userId) async {
    final SharedPreferences? prefs = await _instance;
    prefs!.setString(userIdKey, userId);
  }

  static Future<String> getUserId() async {
    final SharedPreferences? prefs = await _instance;
    return prefs!.getString(userIdKey) ?? "";
  }

  static Future<void> putString(String key, String value) async {
    final SharedPreferences? prefs = await _instance;
    prefs!.setString(key, value);
  }

  static Future<String> getString(String key) async {
    final SharedPreferences? prefs = await _instance;
    return prefs!.getString(key) ?? "";
  }

  static Future<void> putInt(String key, int value) async {
    final SharedPreferences? prefs = await _instance;
    prefs!.setInt(key, value);
  }

  static Future<int> getInt(String key) async {
    final SharedPreferences? prefs = await _instance;
    return prefs!.getInt(key) ?? 0;
  }

  static Future<void> putBool(String key, bool value) async {
    final SharedPreferences? prefs = await _instance;
    prefs!.setBool(key, value);
  }

  static Future<bool> getBool(String key) async {
    final SharedPreferences? prefs = await _instance;
    return prefs!.getBool(key) ?? false;
  }

  static Future<void> updateStringValue(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<void> updateIntValue(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  static Future<String> getStringFromSharedPrefs(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ??
        ""; // Return an empty string if the value is not present
  }

  static Future<int> getIntFromSharedPrefs(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0; // Return 0 if the value is not present
  }
// Similarly, implement methods for bank details saving and retrieval

// ...
}
