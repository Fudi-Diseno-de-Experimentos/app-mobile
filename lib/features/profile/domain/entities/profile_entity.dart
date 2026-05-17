import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  /// Profile id (`ProfileResource.profileId`). NOT the user id.
  final String id;

  /// The owning user id (`ProfileResource.userId`). This is what chat/company
  /// endpoints expect (targetUserId, senderId, group memberIds, ?userId=).
  final String userId;

  final String username;
  final String name;
  final String lastname;
  final String email;
  final List<String>? roles;
  final String? companyId;
  final String? avatarUrl;

  const ProfileEntity({
    required this.id,
    this.userId = '',
    required this.username,
    required this.name,
    required this.lastname,
    required this.email,
    this.roles,
    this.companyId,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    username,
    name,
    lastname,
    email,
    roles,
    companyId,
    avatarUrl,
  ];
}
