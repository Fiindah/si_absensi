import 'package:aplikasi_absensi/models/profile_model.dart';

class TrainingDetailResponse {
  final String message;
  final List<Training> data;

  TrainingDetailResponse({required this.message, required this.data});

  factory TrainingDetailResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Training> trainingList =
        list.map((i) => Training.fromJson(i)).toList();

    return TrainingDetailResponse(message: json['message'], data: trainingList);
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data.map((e) => e.toJson()).toList()};
  }
}
