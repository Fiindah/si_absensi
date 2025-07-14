// lib/models/profile_response_model.dart

class ProfileResponse {
  final String message;
  final ProfileData? data;
  final Map<String, dynamic>? errors;

  ProfileResponse({required this.message, this.data, this.errors});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      message: json['message'] ?? 'Gagal mengambil data',
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data?.toJson(), 'errors': errors};
  }
}

class ProfileData {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final dynamic
  batchId; // Menggunakan dynamic karena bisa int atau string dari API
  final dynamic
  trainingId; // Menggunakan dynamic karena bisa int atau string dari API
  final String? jenisKelamin;
  final String? profilePhoto;
  final String? batchKe;
  final String? trainingTitle;
  final Batch? batch;
  final Training? training;
  final String? token;
  final String? onesignalPlayerId; // New field

  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.batchId,
    this.trainingId,
    this.jenisKelamin,
    this.profilePhoto,
    this.batchKe,
    this.trainingTitle,
    this.batch,
    this.training,
    this.token,
    this.onesignalPlayerId, // New field
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      batchId: json['batch_id'], // Keep as dynamic for parsing flexibility
      trainingId:
          json['training_id'], // Keep as dynamic for parsing flexibility
      jenisKelamin: json['jenis_kelamin'],
      profilePhoto: json['profile_photo'],
      batchKe: json['batch_ke'],
      trainingTitle: json['training_title'],
      batch: json['batch'] != null ? Batch.fromJson(json['batch']) : null,
      training:
          json['training'] != null ? Training.fromJson(json['training']) : null,
      token: json['token'],
      onesignalPlayerId: json['onesignal_player_id'], // New field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'batch_id': batchId, // Keep as dynamic for sending flexibility
      'training_id': trainingId, // Keep as dynamic for sending flexibility
      'jenis_kelamin': jenisKelamin,
      'profile_photo': profilePhoto,
      'batch_ke': batchKe,
      'training_title': trainingTitle,
      'batch': batch?.toJson(),
      'training': training?.toJson(),
      'token': token,
      'onesignal_player_id': onesignalPlayerId, // New field
    };
  }
}

// Model Batch (dipindahkan ke sini sebelumnya)
class Batch {
  final int id;
  final String batchKe;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;

  Batch({
    required this.id,
    required this.batchKe,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      batchKe: json['batch_ke'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_ke': batchKe,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Model Training (dipindahkan ke sini sebelumnya)
class Training {
  final int id;
  final String title;
  final String? description;
  final String? participantCount;
  final String? standard;
  final String? duration;
  final String? createdAt;
  final String? updatedAt;

  Training({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      participantCount: json['participant_count'],
      standard: json['standard'],
      duration: json['duration'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'participant_count': participantCount,
      'standard': standard,
      'duration': duration,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
