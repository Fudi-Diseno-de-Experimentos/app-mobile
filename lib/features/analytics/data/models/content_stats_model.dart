import 'package:app_mobile/features/analytics/domain/entities/content_stats_entity.dart';

class ContentStatsModel extends ContentStatsEntity {
  const ContentStatsModel({
    required super.contentId,
    required super.contentTitle,
    required super.totalUsers,
    required super.totalViews,
    required super.viewPercentage,
    required super.notViewedPercentage,
  });

  factory ContentStatsModel.fromJson(Map<String, dynamic> json) {
    return ContentStatsModel(
      contentId: json['announcementId']?.toString() ?? json['eventId']?.toString() ?? '',
      contentTitle: json['announcementTitle']?.toString() ?? json['eventTitle']?.toString() ?? '',
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      viewPercentage: (json['viewPercentage'] as num?)?.toDouble() ?? 0.0,
      notViewedPercentage: (json['notViewedPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
