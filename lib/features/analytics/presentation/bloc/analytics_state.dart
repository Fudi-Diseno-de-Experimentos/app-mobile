import 'package:equatable/equatable.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

/// Emitted on a successful view registration. No UI listens to this today;
/// it exists so the fire-and-forget flow remains observable/testable.
class AnalyticsViewRegistered extends AnalyticsState {
  final String contentId;
  final bool isNewView;

  const AnalyticsViewRegistered({
    required this.contentId,
    required this.isNewView,
  });

  @override
  List<Object> get props => [contentId, isNewView];
}
