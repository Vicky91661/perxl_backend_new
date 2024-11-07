import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferenceUserTokenKey = "USERTOKEN";
  static String sharedPreferenceUserIdKey = "USERID";

  // saving data to SharedPreferences
  static Future<Future<bool>> saveUserLoggedInSharedPreference(bool isUserLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<Future<bool>> saveUserTokenSharedPreference(String userToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(sharedPreferenceUserTokenKey, userToken);
  }
  static Future<Future<bool>> saveUserIdSharedPreference(String userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(sharedPreferenceUserIdKey, userId);
  }

  // fetching data from SharedPreferences
  static Future<bool?> getUserLoggedInSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String?> getUserTokenSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserTokenKey);
  }
  static Future<String?> getUserIdSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserIdKey);
  }
}
