import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_announcements_usecase.dart';
import '../../domain/usecases/get_announcement_by_id_usecase.dart';
import '../../domain/usecases/get_announcements_by_priority_usecase.dart';
import '../../domain/usecases/create_announcement_usecase.dart';
import '../../domain/usecases/update_announcement_usecase.dart';
import '../../domain/usecases/delete_announcement_usecase.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final GetAnnouncementsUseCase getAnnouncementsUseCase;
  final GetAnnouncementByIdUseCase getAnnouncementByIdUseCase;
  final GetAnnouncementsByPriorityUseCase getAnnouncementsByPriorityUseCase;
  final CreateAnnouncementUseCase createAnnouncementUseCase;
  final UpdateAnnouncementUseCase updateAnnouncementUseCase;
  final DeleteAnnouncementUseCase deleteAnnouncementUseCase;

  AnnouncementBloc({
    required this.getAnnouncementsUseCase,
    required this.getAnnouncementByIdUseCase,
    required this.getAnnouncementsByPriorityUseCase,
    required this.createAnnouncementUseCase,
    required this.updateAnnouncementUseCase,
    required this.deleteAnnouncementUseCase,
  }) : super(AnnouncementInitial()) {
    on<FetchAnnouncements>(_onFetchAnnouncements);
    on<FetchAnnouncementsByPriority>(_onFetchAnnouncementsByPriority);
    on<FetchAnnouncementById>(_onFetchAnnouncementById);
    on<CreateAnnouncementRequested>(_onCreateAnnouncementRequested);
    on<UpdateAnnouncementRequested>(_onUpdateAnnouncementRequested);
    on<DeleteAnnouncementRequested>(_onDeleteAnnouncementRequested);
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

  Future<void> _onFetchAnnouncementsByPriority(
    FetchAnnouncementsByPriority event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    final priority = event.priority;
    final result = (priority == null || priority.isEmpty)
        ? await getAnnouncementsUseCase()
        : await getAnnouncementsByPriorityUseCase(priority);
    result.fold(
      (failure) => emit(AnnouncementError(failure.message)),
      (announcements) => emit(AnnouncementLoaded(announcements)),
    );
  }

  Future<void> _onFetchAnnouncementById(
    FetchAnnouncementById event,
    Emitter<AnnouncementState> emit,
  ) async {
    final result = await getAnnouncementByIdUseCase(event.id);
    // Background refresh: on failure keep the route-passed data shown rather
    // than emitting an error that would surface a spurious snackbar.
    result.fold(
      (_) {},
      (announcement) => emit(AnnouncementDetailLoaded(announcement)),
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

  Future<void> _onUpdateAnnouncementRequested(
    UpdateAnnouncementRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    final result = await updateAnnouncementUseCase(
      id: event.id,
      title: event.title,
      description: event.description,
      image: event.image,
      priority: event.priority,
    );
    result.fold(
      (failure) => emit(AnnouncementError(failure.message)),
      (updated) => emit(AnnouncementUpdateSuccess(updated)),
    );
  }

  Future<void> _onDeleteAnnouncementRequested(
    DeleteAnnouncementRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());
    final result = await deleteAnnouncementUseCase(event.id);
    result.fold(
      (failure) => emit(AnnouncementError(failure.message)),
      (_) => emit(AnnouncementDeleteSuccess(event.id)),
    );
  }
}
