import 'package:app_mobile/features/analytics/domain/entities/view_registration_entity.dart';

class ViewRegistrationModel extends ViewRegistrationEntity {
  const ViewRegistrationModel({
    required super.viewId,
    required super.userId,
    required super.contentId,
    required super.isNewView,
  });

  // ViewRegistrationResponseResource
  factory ViewRegistrationModel.fromJson(Map<String, dynamic> json) =>
      ViewRegistrationModel(
        viewId: json['viewId']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        contentId: json['contentId']?.toString() ?? '',
        isNewView: json['isNewView'] == true,
      );
}
