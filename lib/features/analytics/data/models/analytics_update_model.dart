import 'package:app_mobile/features/analytics/data/models/content_stats_model.dart';
import 'package:app_mobile/features/analytics/data/models/viewer_model.dart';
import 'package:app_mobile/features/analytics/domain/entities/analytics_update_entity.dart';

class AnalyticsUpdateModel extends AnalyticsUpdateEntity {
  const AnalyticsUpdateModel({
    required super.stats,
    required super.viewers,
  });

  factory AnalyticsUpdateModel.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] as Map<String, dynamic>? ?? {};
    final viewersList = json['viewers'] as List? ?? [];

    return AnalyticsUpdateModel(
      stats: ContentStatsModel.fromJson(statsJson),
      viewers: viewersList
          .map((v) => ViewerModel.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList(),
    );
  }
}
