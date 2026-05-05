import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String username;
  final String name;
  final String lastname;
  final String email;
  final List<String>? roles;
  final String? companyId;
  final String? avatarUrl;

  const ProfileEntity({
    required this.id,
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
    username,
    name,
    lastname,
    email,
    roles,
    companyId,
    avatarUrl,
  ];
}
