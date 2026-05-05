import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String token;
  final String? companyId;

  const UserEntity({
    required this.id,
    required this.username,
    required this.token,
    this.companyId,
  });

  @override
  List<Object?> get props => [id, username, token, companyId];
}
