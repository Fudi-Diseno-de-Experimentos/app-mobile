import 'package:equatable/equatable.dart';

class ContentStatsEntity extends Equatable {
  final String contentId;
  final String contentTitle;
  final int totalUsers;
  final int totalViews;
  final double viewPercentage;
  final double notViewedPercentage;

  const ContentStatsEntity({
    required this.contentId,
    required this.contentTitle,
    required this.totalUsers,
    required this.totalViews,
    required this.viewPercentage,
    required this.notViewedPercentage,
  });

  @override
  List<Object?> get props => [
        contentId,
        contentTitle,
        totalUsers,
        totalViews,
        viewPercentage,
        notViewedPercentage,
      ];
}
