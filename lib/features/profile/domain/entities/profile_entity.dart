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

extension ProfileRolesX on ProfileEntity {
  /// Centralized permission rule for content management (create/edit/delete
  /// announcements and events, see analytics).
  bool get isManagerOrAdmin {
    final r = roles ?? const [];
    return r.contains('ROLE_ADMIN') || r.contains('ROLE_MANAGER');
  }

  /// Uppercase first letters of name + lastname for avatar placeholders.
  String get initials =>
      '${name.isNotEmpty ? name[0] : ''}${lastname.isNotEmpty ? lastname[0] : ''}'
          .toUpperCase();
}

extension MemberLookupX on List<ProfileEntity> {
  /// Member whose *profile id* is [id] (announcement/comment authors store
  /// profile ids), or an "Unknown User" placeholder.
  ProfileEntity byProfileId(String id) => firstWhere(
        (m) => m.id == id,
        orElse: () => ProfileEntity(
          id: id,
          userId: id,
          username: '',
          name: 'Unknown',
          lastname: 'User',
          email: '',
        ),
      );
}
