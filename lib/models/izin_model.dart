class IzinResponse {
  final String message;
  final IzinData data;

  IzinResponse({required this.message, required this.data});

  factory IzinResponse.fromJson(Map<String, dynamic> json) {
    return IzinResponse(
      message: json['message'],
      data: IzinData.fromJson(json['data']),
    );
  }
}

class IzinData {
  final int id;
  final String attendanceDate;
  final String status;
  final String alasanIzin;

  IzinData({
    required this.id,
    required this.attendanceDate,
    required this.status,
    required this.alasanIzin,
  });

  factory IzinData.fromJson(Map<String, dynamic> json) {
    return IzinData(
      id: json['id'],
      attendanceDate: json['attendance_date'],
      status: json['status'],
      alasanIzin: json['alasan_izin'],
    );
  }
}
