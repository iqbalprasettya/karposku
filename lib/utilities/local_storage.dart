// ignore_for_file: avoid_print
// import 'package:glutton/glutton.dart';
// import 'package:karpos/models/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // static Future<bool> save(String key, value) async {
  //   try {
  //     /* Saving data inside glutton */
  //     return await Glutton.eat(key, value);
  //   } on GluttonFormatException catch (e) {
  //     print(e.message);
  //     return false;
  //   }
  // }

  static Future<bool?> save(String key, String value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    return null;
  }

  static Future<dynamic> load(String key) async {
    /* Retrieve data inside glutton */
    // return await Glutton.vomit(key);
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  static void remove(String key) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  // static Future<bool> remove(String key) async {
  //   /* Remove data inside glutton */
  //   return await Glutton.digest(key);
  // }

  // static Future<bool> check(String key) async {
  //   /* Check if data is exist inside glutton */
  //   return await Glutton.have(key);
  // }

  // static Future<bool> deleteAll() async {
  //   /* Clear all data inside glutton */
  //   return await Glutton.flush();
  // }

  // static Future<bool> saveUser(String userKey, UserData userData) async {
  //   try {
  //     Map userMap = userData.toJson();
  //     bool isSuccess = await Glutton.eat(userKey, userMap);
  //     return isSuccess;
  //   } on GluttonFormatException catch (e) {
  //     print(e.message);
  //     return false;
  //   }
  // }

  // static Future<UserData> loadUser(String userKey) async {
  //   // Map<String, dynamic>? userMap = await Glutton.vomit(userKey);
  //   var prefs = await SharedPreferences.getInstance();
  //   Map<String, dynamic>? userMap = await Glutton.vomit(userKey);
  //   UserData userData = UserData.fromJson(userMap!);
  //   return userData;
  // }

  // static Future<bool> saveDevice(
  //     String deviceKey, BluetoothDevice bluetoothDevice) async {
  //   try {
  //     Map bluetoothMap = bluetoothDevice.toJson();
  //     bool isSuccess = await Glutton.eat(deviceKey, bluetoothMap);
  //     return isSuccess;
  //   } on GluttonFormatException catch (e) {
  //     print(e.message);
  //     return false;
  //   }
  // }

  // static Future<BluetoothDevice> loadDevice(String deviceKey) async {
  //   Map<String, dynamic>? deviceMap = await Glutton.vomit(deviceKey);
  //   BluetoothDevice deviceData = BluetoothDevice.fromJson(deviceMap!);
  //   return deviceData;
  // }
}
