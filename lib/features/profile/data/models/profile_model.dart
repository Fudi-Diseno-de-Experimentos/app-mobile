import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.username,
    required super.name,
    required super.lastname,
    required super.email,
    super.roles,
    super.companyId,
    super.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['profileId']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      name: json['firstName'] ?? json['name'] ?? '',
      lastname: json['lastName'] ?? json['lastname'] ?? '',
      email: json['email'] ?? '',
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
      companyId: json['companyId']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': name,
      'lastName': lastname,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }
}
