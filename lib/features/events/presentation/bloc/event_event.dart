import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object> get props => [];
}

class FetchEvents extends EventEvent {}

class CreateEventRequested extends EventEvent {
  final String title;
  final String description;
  final String date;
  final String location;
  final String createdBy;
  final List<String> recipientIds;

  const CreateEventRequested({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.createdBy,
    required this.recipientIds,
  });

  @override
  List<Object> get props => [title, description, date, location, createdBy, recipientIds];
}
