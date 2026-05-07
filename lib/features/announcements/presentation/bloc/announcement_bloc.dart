import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_announcements_usecase.dart';
import '../../domain/usecases/create_announcement_usecase.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final GetAnnouncementsUseCase getAnnouncementsUseCase;
  final CreateAnnouncementUseCase createAnnouncementUseCase;

  AnnouncementBloc({
    required this.getAnnouncementsUseCase,
    required this.createAnnouncementUseCase,
  }) : super(AnnouncementInitial()) {
    on<FetchAnnouncements>(_onFetchAnnouncements);
    on<CreateAnnouncementRequested>(_onCreateAnnouncementRequested);
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

  Future<void> _onCreateAnnouncementRequested(
    CreateAnnouncementRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    final failureOrAnnouncement = await createAnnouncementUseCase(
      title: event.title,
      description: event.description,
      image: event.image,
      priority: event.priority,
      createdBy: event.createdBy,
    );

    failureOrAnnouncement.fold(
      (failure) => emit(AnnouncementError(failure.message)),
      (announcement) {
        emit(AnnouncementCreateSuccess());
        add(FetchAnnouncements()); // Refresh list
      },
    );
  }
}
