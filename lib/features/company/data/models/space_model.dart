import 'package:app_mobile/features/company/domain/entities/space_entity.dart';

class SpaceModel extends SpaceEntity {
  const SpaceModel({
    required super.id,
    required super.name,
    super.description,
    required super.companyId,
    super.available,
  });

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      companyId: json['companyId'] as String? ?? '',
      available: json['available'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'companyId': companyId,
      'available': available,
    };
  }
}
