import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_events_usecase.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEventsUseCase getEventsUseCase;

  EventBloc({required this.getEventsUseCase}) : super(EventInitial()) {
    on<FetchEvents>(_onFetchEvents);
  }

  Future<void> _onFetchEvents(
    FetchEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final failureOrEvents = await getEventsUseCase();
    failureOrEvents.fold(
      (failure) => emit(EventError(failure.message)),
      (events) => emit(EventLoaded(events)),
    );
  }
}
