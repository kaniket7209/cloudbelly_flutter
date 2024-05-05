import 'package:cloudbelly_app/models/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPreferences {
  static SharedPreferences? _preferences;

  static const String _userKey = 'user';

  static Future init() async => _preferences = await SharedPreferences.getInstance();
  static Future clear() async => _preferences?.clear();

 /* static Future setUser(UserModel user) async {
    final json = jsonEncode(user.toJson());
    await _preferences?.setString(_keyUser, json);
  }

  static UserModel? getUser() {
    final json = _preferences?.getString(_keyUser);
    return json == null ? null : UserModel.fromJson(jsonDecode(json));
  }*/

  bool get isLogin => _preferences?.getBool("isLogin") ?? false;

  set isLogin(bool value) => _preferences?.setBool("isLogin", value);


  static Future setUser(Map<String, dynamic> userData) async {
    String jsonString = jsonEncode(userData);
    await _preferences?.setString(_userKey, jsonString);
  }

  static Map<String, dynamic>? getUser() {
    String? jsonString = _preferences?.getString(_userKey);
    return jsonString == null ? null : jsonDecode(jsonString);
  }
}