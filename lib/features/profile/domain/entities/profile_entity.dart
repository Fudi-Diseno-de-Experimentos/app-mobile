import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String username;
  final String name;
  final String lastname;
  final String email;
  final List<String>? roles;

  const ProfileEntity({
    required this.id,
    required this.username,
    required this.name,
    required this.lastname,
    required this.email,
    this.roles,
  });

  @override
  List<Object?> get props => [id, username, name, lastname, email, roles];
}
