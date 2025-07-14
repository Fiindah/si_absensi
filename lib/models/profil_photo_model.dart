// lib/models/profile_photo_update_response_model.dart

class ProfilePhotoUpdateResponse {
  final String message;
  final ProfilePhotoData? data;

  ProfilePhotoUpdateResponse({required this.message, this.data});

  factory ProfilePhotoUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfilePhotoUpdateResponse(
      message: json['message'] ?? 'Gagal memperbarui foto profil',
      data:
          json['data'] != null ? ProfilePhotoData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data?.toJson()};
  }
}

class ProfilePhotoData {
  final String profilePhotoUrl;

  ProfilePhotoData({required this.profilePhotoUrl});

  factory ProfilePhotoData.fromJson(Map<String, dynamic> json) {
    return ProfilePhotoData(profilePhotoUrl: json['profile_photo']);
  }

  Map<String, dynamic> toJson() {
    return {'profile_photo': profilePhotoUrl};
  }
}
