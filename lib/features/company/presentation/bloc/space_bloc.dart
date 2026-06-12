import 'package:app_mobile/features/company/domain/usecases/create_space_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/delete_space_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/get_spaces_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/update_space_usecase.dart';
import 'package:app_mobile/features/company/presentation/bloc/space_event.dart';
import 'package:app_mobile/features/company/presentation/bloc/space_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpaceBloc extends Bloc<SpaceEvent, SpaceState> {
  final GetSpacesUseCase getSpacesUseCase;
  final CreateSpaceUseCase createSpaceUseCase;
  final UpdateSpaceUseCase updateSpaceUseCase;
  final DeleteSpaceUseCase deleteSpaceUseCase;

  SpaceBloc({
    required this.getSpacesUseCase,
    required this.createSpaceUseCase,
    required this.updateSpaceUseCase,
    required this.deleteSpaceUseCase,
  }) : super(SpaceInitial()) {
    on<FetchSpaces>(_onFetchSpaces);
    on<CreateSpaceRequested>(_onCreateSpaceRequested);
    on<UpdateSpaceRequested>(_onUpdateSpaceRequested);
    on<DeleteSpaceRequested>(_onDeleteSpaceRequested);
  }

  Future<void> _onFetchSpaces(
    FetchSpaces event,
    Emitter<SpaceState> emit,
  ) async {
    emit(SpaceLoading());
    final result = await getSpacesUseCase(date: event.date);
    result.fold(
      (failure) => emit(SpaceError(failure.message)),
      (spaces) => emit(SpacesLoaded(spaces)),
    );
  }

  Future<void> _onCreateSpaceRequested(
    CreateSpaceRequested event,
    Emitter<SpaceState> emit,
  ) async {
    emit(SpaceLoading());
    final result = await createSpaceUseCase(
      name: event.name,
      description: event.description,
    );
    await result.fold(
      (failure) async => emit(SpaceError(failure.message)),
      (_) async {
        emit(const SpaceActionSuccess('Room created'));
        add(const FetchSpaces());
      },
    );
  }

  Future<void> _onUpdateSpaceRequested(
    UpdateSpaceRequested event,
    Emitter<SpaceState> emit,
  ) async {
    emit(SpaceLoading());
    final result = await updateSpaceUseCase(
      id: event.id,
      name: event.name,
      description: event.description,
    );
    await result.fold(
      (failure) async => emit(SpaceError(failure.message)),
      (_) async {
        emit(const SpaceActionSuccess('Room updated'));
        add(const FetchSpaces());
      },
    );
  }

  Future<void> _onDeleteSpaceRequested(
    DeleteSpaceRequested event,
    Emitter<SpaceState> emit,
  ) async {
    emit(SpaceLoading());
    final result = await deleteSpaceUseCase(event.id);
    await result.fold(
      (failure) async => emit(SpaceError(failure.message)),
      (_) async {
        emit(const SpaceActionSuccess('Room deleted'));
        add(const FetchSpaces());
      },
    );
  }
}
