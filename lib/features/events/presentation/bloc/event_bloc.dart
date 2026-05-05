import 'package:flutter_bloc/flutter_bloc.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  EventBloc() : super(InitialEventState()) {
    on<EventEvent>((event, emit) { });
  }
}

class InitialEventState extends EventState {}
