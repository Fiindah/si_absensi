import 'package:aplikasi_absensi/models/profile_model.dart';

class RegisterResponse {
  final String message;
  final RegisterData? data;
  final Map<String, dynamic>? errors;

  RegisterResponse({required this.message, this.data, this.errors});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? 'Terjadi kesalahan tidak dikenal',
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data?.toJson(), 'errors': errors};
  }
}

class RegisterData {
  final String token;
  final ProfileData user; // Menggunakan ProfileData
  final String? profilePhotoUrl;

  RegisterData({required this.token, required this.user, this.profilePhotoUrl});

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    final userJson = Map<String, dynamic>.from(json['user']);
    userJson['token'] =
        json['token']; // Tambahkan token ke userJson untuk ProfileData

    return RegisterData(
      token: json['token'],
      user: ProfileData.fromJson(userJson), // Meneruskan token ke ProfileData
      profilePhotoUrl: json['profile_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'profile_photo_url': profilePhotoUrl,
    };
  }
}
