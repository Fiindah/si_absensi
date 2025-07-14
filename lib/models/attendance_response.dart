import 'attendance_model.dart';

class AttendanceResponse {
  final String? message;
  final Map<String, dynamic>? errors;
  final AttendanceData? data;

  AttendanceResponse({this.message, this.errors, this.data});

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      message: json['message'],
      errors: json['errors'],
      data: json['data'] != null ? AttendanceData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'errors': errors, 'data': data?.toJson()};
  }
}
