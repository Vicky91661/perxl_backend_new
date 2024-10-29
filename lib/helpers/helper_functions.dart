import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferenceUserPhoneKey = "USERPHONEKEY";
  static String sharedPreferenceUserFirstNameKey = "USERFIRSTNAMEKEY";
  static String sharedPreferenceUserLastNameKey = "USERLASTNAMEKEY";

  // saving data to SharedPreferences
  static Future<Future<bool>> saveUserLoggedInSharedPreference(bool isUserLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<Future<bool>> saveUserPhoneSharedPreference(String userPhone) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(sharedPreferenceUserPhoneKey, userPhone);
  }

  static Future<Future<bool>> saveUserFirstNameSharedPreference(String userFirstName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(sharedPreferenceUserFirstNameKey, userFirstName);
  }

  static Future<Future<bool>> saveUserLastNameSharedPreference(String userLastName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(sharedPreferenceUserLastNameKey, userLastName);
  }

  // fetching data from SharedPreferences
  static Future<bool?> getUserLoggedInSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String?> getUserPhoneSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserPhoneKey);
  }

  static Future<String?> getUserFirstNameSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserFirstNameKey);
  }

  static Future<String?> getUserLastNameSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserLastNameKey);
  }
}
