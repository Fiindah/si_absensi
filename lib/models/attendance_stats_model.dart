// lib/models/attendance_stats_model.dart

class AttendanceStatsResponse {
  final String message;
  final AttendanceStatsData? data;
  final Map<String, dynamic>? errors;

  AttendanceStatsResponse({required this.message, this.data, this.errors});

  factory AttendanceStatsResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceStatsResponse(
      message: json['message'] ?? 'Gagal mengambil statistik absensi',
      data:
          json['data'] != null
              ? AttendanceStatsData.fromJson(json['data'])
              : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data?.toJson(), 'errors': errors};
  }
}

class AttendanceStatsData {
  final int totalAbsen;
  final int totalMasuk;
  final int totalIzin;
  final bool sudahAbsenHariIni;

  AttendanceStatsData({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
  });

  factory AttendanceStatsData.fromJson(Map<String, dynamic> json) {
    return AttendanceStatsData(
      totalAbsen: json['total_absen'] ?? 0,
      totalMasuk: json['total_masuk'] ?? 0,
      totalIzin: json['total_izin'] ?? 0,
      sudahAbsenHariIni: json['sudah_absen_hari_ini'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_absen': totalAbsen,
      'total_masuk': totalMasuk,
      'total_izin': totalIzin,
      'sudah_absen_hari_ini': sudahAbsenHariIni,
    };
  }
}
