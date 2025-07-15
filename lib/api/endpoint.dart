// lib/constant/endpoint.dart

class Endpoint {
  static const String baseUrl = "https://appabsensi.mobileprojp.com";
  static const String baseUrlApi = "$baseUrl/api";
  static const String register = "$baseUrlApi/register";
  static const String login = "$baseUrlApi/login";
  static const String forgotPassword = "$baseUrlApi/forgot-password";
  static const String resetPassword = "$baseUrlApi/reset-password";
  static const String batches = "$baseUrlApi/batches";
  static const String trainings = "$baseUrlApi/trainings";
  static const String trainingDetail = "$baseUrlApi/trainings";
  static const String profile = "$baseUrlApi/profile";
  static const String updateProfile = "$baseUrlApi/profile";
  static const String updateProfilePhoto = "$baseUrlApi/profile/photo";
  static const String absenToday = "$baseUrlApi/absen/today";
  static const String absenCheckIn = "$baseUrlApi/absen/check-in";
  static const String absenCheckOut = "$baseUrlApi/absen/check-out";
  static const String absenHistory = "$baseUrlApi/absen/history";
  static const String absenIzin = "$baseUrlApi/izin";
  static const String absenStats = "$baseUrlApi/absen/stats";
}
