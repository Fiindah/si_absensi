import 'dart:convert';

import 'package:aplikasi_absensi/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  static Future<bool> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Metode untuk menyimpan data pengguna (objek ProfileData)
  static Future<bool> saveUserData(ProfileData user) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = jsonEncode(user.toJson());
    return prefs.setString(_userDataKey, userDataJson);
  }

  // Metode untuk mengambil data pengguna (objek ProfileData)
  static Future<ProfileData?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userDataKey);
    if (userDataJson != null) {
      // Konversi string JSON kembali menjadi objek ProfileData
      return ProfileData.fromJson(jsonDecode(userDataJson));
    }
    return null;
  }

  // Metode untuk menghapus semua data yang tersimpan (saat logout)
  static Future<bool> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
