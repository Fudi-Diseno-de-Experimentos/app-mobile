import 'package:equatable/equatable.dart';

/// Result of registering a content view (announcement or event).
class ViewRegistrationEntity extends Equatable {
  final String viewId;
  final String userId;
  final String contentId;
  final bool isNewView;

  const ViewRegistrationEntity({
    required this.viewId,
    required this.userId,
    required this.contentId,
    required this.isNewView,
  });

  @override
  List<Object?> get props => [viewId, userId, contentId, isNewView];
}
