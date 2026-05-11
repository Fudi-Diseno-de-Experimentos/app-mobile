import 'package:equatable/equatable.dart';
import '../../domain/entities/event_entity.dart';
import '../../../profile/domain/entities/profile_entity.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<EventEntity> events;

  const EventLoaded(this.events);

  @override
  List<Object> get props => [events];
}

class EventMembersLoaded extends EventState {
  final List<ProfileEntity> members;

  const EventMembersLoaded(this.members);

  @override
  List<Object> get props => [members];
}

class EventCreateSuccess extends EventState {}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object> get props => [message];
}
