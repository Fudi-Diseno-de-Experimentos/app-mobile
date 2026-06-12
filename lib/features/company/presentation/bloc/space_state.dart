import 'package:app_mobile/features/company/domain/entities/space_entity.dart';
import 'package:equatable/equatable.dart';

abstract class SpaceState extends Equatable {
  const SpaceState();

  @override
  List<Object?> get props => [];
}

class SpaceInitial extends SpaceState {}

class SpaceLoading extends SpaceState {}

class SpacesLoaded extends SpaceState {
  final List<SpaceEntity> spaces;

  const SpacesLoaded(this.spaces);

  @override
  List<Object?> get props => [spaces];
}

/// Emitted after a successful create/update/delete so the page can show a
/// confirmation. The list is reloaded right after.
class SpaceActionSuccess extends SpaceState {
  final String message;

  const SpaceActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SpaceError extends SpaceState {
  final String message;

  const SpaceError(this.message);

  @override
  List<Object?> get props => [message];
}
