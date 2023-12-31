import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSharedPreferences {
  static SharedPreferences? sharedPreferences;
  static const String _userTokenKey = "userTokenKey";
  static const String _userPhoneNumKey = "userPhoneNumKey";
  static const String _loggedInKey = "loggedInKey";
  static const String _mapGeoLocKey = "mapgeolocKey";
  static const String _deviceModelKey = "deviceModelKey";

  static Future init() async =>
      sharedPreferences = await SharedPreferences.getInstance();

  static Future setUserToken(String token) async {
    try {
      await sharedPreferences!.setString(_userTokenKey, token);
    } catch (e) {
      debugPrint("setUserToken: ${e.toString()}");
      Future.error("Something went wrong while"
          "\nsaving user data on device");
    }
  }

  static String? getUserToken() {
    try {
      if (sharedPreferences == null) {
        debugPrint("SharedPref Null");
      }
      String? token = sharedPreferences!.getString(_userTokenKey);
      return token != null
          ? token.isEmpty
              ? null
              : token
          : null;
    } catch (e) {
      return null;
    }
  }

  static Future setDeviceInfo(String model) async {
    try {
      await sharedPreferences!.setString(_deviceModelKey, model);
    } catch (e) {
      debugPrint("setDeviceInfo: ${e.toString()}");
      Future.error("Something went wrong while"
          "\nsaving user data on device");
    }
  }

  static String? getDeviceInfo() {
    try {
      String? model = sharedPreferences!.getString(_deviceModelKey);
      return model != null
          ? model.isEmpty
              ? null
              : model
          : null;
    } catch (e) {
      return null;
    }
  }

  static Future setUserPhoneNum(String phoneNum) async {
    try {
      await sharedPreferences!.setString(_userPhoneNumKey, phoneNum);
    } catch (e) {
      debugPrint("setUserToken: ${e.toString()}");
      Future.error("Something went wrong while"
          "\nsaving user data on device");
    }
  }

  static String? getUserPhoneNum() {
    try {
      String? num = sharedPreferences!.getString(_userPhoneNumKey);
      return num != null
          ? num.isEmpty
              ? null
              : num
          : null;
    } catch (e) {
      return null;
    }
  }

  static Future setLoggedInOrNot(bool loggedIn) async {
    try {
      await sharedPreferences!.setBool(_loggedInKey, loggedIn);
    } catch (e) {
      debugPrint("setLoggedInOrNot: ${e.toString()}");
      Future.error("Something went wrong while"
          "\nsaving user data on device");
    }
  }

  static bool getLoggedInOrNot() {
    try {
      return sharedPreferences!.getBool(_loggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future setMapGeoLoc(double lat, double long) async {
    try {
      await sharedPreferences!
          .setStringList(_mapGeoLocKey, [lat.toString(), long.toString()]);
    } catch (e) {
      debugPrint("setMapGeoLoc: ${e.toString()}");
      Future.error("Something went wrong while"
          "\nsaving user data on device");
    }
  }

  static List<double?> getMapGeoLoc() {
    try {
      return [
        double.parse(sharedPreferences!.getStringList(_mapGeoLocKey)![0]),
        double.parse(sharedPreferences!.getStringList(_mapGeoLocKey)![1])
      ];
    } catch (e) {
      debugPrint("getMapGeoLoc: ${e.toString()}");
      return [];
    }
  }

  // static Future setRideBool(bool riding) async {
  //   try {
  //     await sharedPreferences!.setBool(_rideBoolKey, riding);
  //   } catch (e) {
  //     debugPrint("setRideBool: ${e.toString()}");
  //     Future.error("Something went wrong while"
  //         "\nsaving user data on device");
  //   }
  // }

  // static bool getRideBool() {
  //   try {
  //     return sharedPreferences!.getBool(_rideBoolKey) ?? false;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // static Future setRideState(String bookId) async {
  //   try {
  //     await sharedPreferences!.setString(_rideStateKey, bookId);
  //   } catch (e) {
  //     debugPrint("setRideState: ${e.toString()}");
  //     Future.error("Something went wrong while"
  //         "\nsaving user data on device");
  //   }
  // }

  // static String? getRideState() {
  //   try {
  //     return sharedPreferences!.getString(_rideStateKey);
  //   } catch (e) {
  //     debugPrint("getRideState: ${e.toString()}");
  //     return null;
  //   }
  // }
}
