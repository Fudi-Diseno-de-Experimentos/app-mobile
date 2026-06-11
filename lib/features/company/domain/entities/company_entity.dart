import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  final String id;
  final String ruc;
  final String name;
  final String? iconUrl;
  final bool isActive;
  final String userId;
  final String joinCode;

  const CompanyEntity({
    required this.id,
    required this.ruc,
    required this.name,
    this.iconUrl,
    required this.isActive,
    required this.userId,
    required this.joinCode,
  });

  @override
  List<Object?> get props => [id, ruc, name, iconUrl, isActive, userId, joinCode];
}
