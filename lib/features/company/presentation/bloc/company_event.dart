import 'package:equatable/equatable.dart';

abstract class CompanyEvent extends Equatable {
  const CompanyEvent();

  @override
  List<Object?> get props => [];
}

class CreateCompanyRequested extends CompanyEvent {
  final String ruc;
  final String nombre;
  final String? iconUrl;
  final bool isActive;
  final String userId;

  const CreateCompanyRequested({
    required this.ruc,
    required this.nombre,
    this.iconUrl,
    required this.isActive,
    required this.userId,
  });

  @override
  List<Object?> get props => [ruc, nombre, iconUrl, isActive, userId];
}

class UpdateCompanyRequested extends CompanyEvent {
  final String id;
  final String ruc;
  final String nombre;
  final String? iconUrl;
  final bool isActive;

  const UpdateCompanyRequested({
    required this.id,
    required this.ruc,
    required this.nombre,
    this.iconUrl,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, ruc, nombre, iconUrl, isActive];
}

class GetCompanyRequested extends CompanyEvent {
  final String userId;

  const GetCompanyRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
