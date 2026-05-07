import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_announcements_usecase.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final GetAnnouncementsUseCase getAnnouncementsUseCase;

  AnnouncementBloc({required this.getAnnouncementsUseCase}) : super(AnnouncementInitial()) {
    on<FetchAnnouncements>(_onFetchAnnouncements);
  }

  Future<void> _onFetchAnnouncements(
    FetchAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    final failureOrAnnouncements = await getAnnouncementsUseCase();
    failureOrAnnouncements.fold(
      (failure) => emit(AnnouncementError(failure.message)),
      (announcements) => emit(AnnouncementLoaded(announcements)),
    );
  }
}
