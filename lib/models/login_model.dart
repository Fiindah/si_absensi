import 'package:aplikasi_absensi/models/profile_model.dart';

class LoginResponse {
  final String message;
  final LoginData? data;
  final Map<String, dynamic>? errors;

  LoginResponse({required this.message, this.data, this.errors});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? 'Terjadi kesalahan tidak dikenal',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data?.toJson(), 'errors': errors};
  }
}

class LoginData {
  final String token;
  final ProfileData user;

  LoginData({required this.token, required this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    final userJson = Map<String, dynamic>.from(json['user']);
    userJson['token'] =
        json['token']; // Tambahkan token ke userJson untuk ProfileData

    return LoginData(
      token: json['token'],
      user: ProfileData.fromJson(userJson), // Meneruskan token ke ProfileData
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson()};
  }
}
