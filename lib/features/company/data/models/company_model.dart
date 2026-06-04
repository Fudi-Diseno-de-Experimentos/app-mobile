import '../../domain/entities/company_entity.dart';

class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.id,
    required super.ruc,
    required super.nombre,
    super.iconUrl,
    required super.isActive,
    required super.userId,
    required super.joinCode,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      ruc: json['ruc'] as String,
      nombre: json['nombre'] as String,
      iconUrl: json['iconUrl'] as String?,
      isActive: json['isActive'] as bool,
      userId: json['userId'] as String,
      joinCode: json['joinCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ruc': ruc,
      'nombre': nombre,
      'iconUrl': iconUrl,
      'isActive': isActive,
      'userId': userId,
      'joinCode': joinCode,
    };
  }
}
