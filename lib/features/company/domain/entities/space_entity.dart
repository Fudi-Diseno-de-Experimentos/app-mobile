import 'package:equatable/equatable.dart';

class SpaceEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String companyId;

  /// Per-day availability. Only populated when spaces are fetched with a
  /// `date` (the event-creation picker). `null` on the management screen,
  /// which lists spaces without a date.
  final bool? available;

  const SpaceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.companyId,
    this.available,
  });

  @override
  List<Object?> get props => [id, name, description, companyId, available];
}
