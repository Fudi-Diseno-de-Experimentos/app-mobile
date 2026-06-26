import 'package:equatable/equatable.dart';

abstract class SpaceEvent extends Equatable {
  const SpaceEvent();

  @override
  List<Object?> get props => [];
}

class FetchSpaces extends SpaceEvent {
  /// Optional day (`YYYY-MM-DD`) to compute per-space availability.
  final String? date;

  const FetchSpaces({this.date});

  @override
  List<Object?> get props => [date];
}

class CreateSpaceRequested extends SpaceEvent {
  final String name;
  final String? description;

  const CreateSpaceRequested({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class UpdateSpaceRequested extends SpaceEvent {
  final String id;
  final String name;
  final String? description;

  const UpdateSpaceRequested({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

class DeleteSpaceRequested extends SpaceEvent {
  final String id;

  const DeleteSpaceRequested(this.id);

  @override
  List<Object?> get props => [id];
}
