import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/job_seeker/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    super.id,
    super.fullName,
    super.email,
    super.dateOfBirth,
    super.gender,
    super.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // If the JSON is the root response containing 'profile' and/or 'user'
    final containsKeys =
        json.containsKey('profile') || json.containsKey('user');

    if (containsKeys) {
      final profileData = json['profile'] as DataMap?;
      final userData = json['user'] as DataMap?;

      if (profileData != null) {
        return ProfileModel(
          id: profileData['id']?.toString() ?? profileData['_id']?.toString(),
          fullName: profileData['fullName'],
          email: profileData['email'],
          dateOfBirth: profileData['dateOfBirth'],
          gender: profileData['gender'],
          avatarUrl: profileData['avatarUrl'],
        );
      }

      // Fallback to user data if profile is null
      return ProfileModel(
        id: userData?['id']?.toString(),
        fullName: userData?['name'],
        email: userData?['email'],
        avatarUrl: userData?['avatarUrl'],
      );
    }

    // If it's the direct profile data (no 'profile' or 'user' at root)
    return ProfileModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      fullName: json['fullName'],
      email: json['email'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      avatarUrl: json['avatarUrl'],
    );
  }

  DataMap toJson() {
    return {
      if (id != null) 'id': id,
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? dateOfBirth,
    String? gender,
    String? avatarUrl,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
