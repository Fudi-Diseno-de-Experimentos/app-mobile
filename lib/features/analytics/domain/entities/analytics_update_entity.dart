import 'package:app_mobile/features/analytics/domain/entities/content_stats_entity.dart';
import 'package:app_mobile/features/analytics/domain/entities/viewer_entity.dart';
import 'package:equatable/equatable.dart';

class AnalyticsUpdateEntity extends Equatable {
  final ContentStatsEntity stats;
  final List<ViewerEntity> viewers;

  const AnalyticsUpdateEntity({
    required this.stats,
    required this.viewers,
  });

  @override
  List<Object?> get props => [stats, viewers];
}
