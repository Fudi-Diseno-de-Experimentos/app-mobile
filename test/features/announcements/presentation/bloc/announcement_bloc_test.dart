import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/generate_mocks.mocks.dart';
import '../../../../mocks/mock_helpers.dart';

void main() {
  late MockGetAnnouncementsUseCase mockGetAnnouncements;
  late MockGetAnnouncementByIdUseCase mockGetAnnouncementById;
  late MockGetAnnouncementsByPriorityUseCase mockGetByPriority;
  late MockGetAnnouncementsByCreatorUseCase mockGetByCreator;
  late MockCreateAnnouncementUseCase mockCreate;
  late MockUpdateAnnouncementUseCase mockUpdate;
  late MockDeleteAnnouncementUseCase mockDelete;
  late AnnouncementBloc bloc;

  const tAnnouncement = AnnouncementEntity(
    id: 'ann-1',
    title: 'Test Announcement',
    description: 'Contenido',
    priority: 'NORMAL',
    createdBy: 'user-1',
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
  );

  const tAnnouncementHigh = AnnouncementEntity(
    id: 'ann-2',
    title: 'Urgente',
    description: 'Prioritario',
    priority: 'HIGH',
    createdBy: 'user-1',
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
  );

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockGetAnnouncements = MockGetAnnouncementsUseCase();
    mockGetAnnouncementById = MockGetAnnouncementByIdUseCase();
    mockGetByPriority = MockGetAnnouncementsByPriorityUseCase();
    mockGetByCreator = MockGetAnnouncementsByCreatorUseCase();
    mockCreate = MockCreateAnnouncementUseCase();
    mockUpdate = MockUpdateAnnouncementUseCase();
    mockDelete = MockDeleteAnnouncementUseCase();
    bloc = AnnouncementBloc(
      getAnnouncementsUseCase: mockGetAnnouncements,
      getAnnouncementByIdUseCase: mockGetAnnouncementById,
      getAnnouncementsByPriorityUseCase: mockGetByPriority,
      getAnnouncementsByCreatorUseCase: mockGetByCreator,
      createAnnouncementUseCase: mockCreate,
      updateAnnouncementUseCase: mockUpdate,
      deleteAnnouncementUseCase: mockDelete,
    );
  });

  tearDown(() => bloc.close());

  group('US10 - Basic announcement publishing', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'should emit [Loading, Loaded] when announcements are fetched successfully',
      build: () {
        when(mockGetAnnouncements())
            .thenAnswer((_) async => const Right([tAnnouncement]));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchAnnouncements()),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementLoaded([tAnnouncement]),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'should emit [Loading, Error] when fetching announcements fails',
      build: () {
        when(mockGetAnnouncements())
            .thenAnswer((_) async => const Left(ServerFailure('Error del servidor')));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchAnnouncements()),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementError('Error del servidor'),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'should emit [Loading, CreateSuccess, Loading, Loaded] when an announcement is created successfully',
      build: () {
        when(mockCreate(
          title: anyNamed('title'),
          description: anyNamed('description'),
          image: anyNamed('image'),
          priority: anyNamed('priority'),
          createdBy: anyNamed('createdBy'),
        )).thenAnswer((_) async => const Right(tAnnouncement));
        when(mockGetAnnouncements())
            .thenAnswer((_) async => const Right([tAnnouncement]));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateAnnouncementRequested(
        title: 'Test Announcement',
        description: 'Contenido',
        priority: 'NORMAL',
        createdBy: 'user-1',
      )),
      expect: () => [
        AnnouncementLoading(),
        AnnouncementCreateSuccess(),
        AnnouncementLoading(),
        const AnnouncementLoaded([tAnnouncement]),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'should emit [Loading, Error] when announcement creation fails',
      build: () {
        when(mockCreate(
          title: anyNamed('title'),
          description: anyNamed('description'),
          image: anyNamed('image'),
          priority: anyNamed('priority'),
          createdBy: anyNamed('createdBy'),
        )).thenAnswer((_) async => const Left(ServerFailure('No autorizado')));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateAnnouncementRequested(
        title: 'Test',
        description: 'Desc',
        priority: 'NORMAL',
        createdBy: 'user-1',
      )),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementError('No autorizado'),
      ],
    );
  });

  group('US11 - Announcement prioritization', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'should filter announcements by HIGH priority',
      build: () {
        when(mockGetByPriority('HIGH'))
            .thenAnswer((_) async => const Right([tAnnouncementHigh]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAnnouncementsByPriority('HIGH')),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementLoaded([tAnnouncementHigh]),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'should load all announcements when the priority is null',
      build: () {
        when(mockGetAnnouncements())
            .thenAnswer((_) async => const Right([tAnnouncement, tAnnouncementHigh]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAnnouncementsByPriority(null)),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementLoaded([tAnnouncement, tAnnouncementHigh]),
      ],
      verify: (_) {
        verifyNever(mockGetByPriority(any));
      },
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'should load all announcements when the priority is an empty string',
      build: () {
        when(mockGetAnnouncements())
            .thenAnswer((_) async => const Right([tAnnouncement]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAnnouncementsByPriority('')),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementLoaded([tAnnouncement]),
      ],
    );
  });

  group('US12 - Announcement editing', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'should emit [Loading, UpdateSuccess] when an announcement updates successfully',
      build: () {
        const updated = AnnouncementEntity(
          id: 'ann-1',
          title: 'Updated Title',
          description: 'New description',
          priority: 'HIGH',
          createdBy: 'user-1',
          createdAt: '2024-01-01',
          updatedAt: '2024-01-02',
        );
        when(mockUpdate(
          id: anyNamed('id'),
          title: anyNamed('title'),
          description: anyNamed('description'),
          image: anyNamed('image'),
          priority: anyNamed('priority'),
        )).thenAnswer((_) async => const Right(updated));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateAnnouncementRequested(
        id: 'ann-1',
        title: 'Updated Title',
        description: 'New description',
        priority: 'HIGH',
      )),
      expect: () => [
        AnnouncementLoading(),
        isA<AnnouncementUpdateSuccess>(),
      ],
    );
  });

  group('US13 - Announcement deletion', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'should emit [Loading, DeleteSuccess] when an announcement is deleted successfully',
      build: () {
        when(mockDelete('ann-1'))
            .thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteAnnouncementRequested('ann-1')),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementDeleteSuccess('ann-1'),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'should emit [Loading, Error] when the deletion fails',
      build: () {
        when(mockDelete('ann-1'))
            .thenAnswer((_) async => const Left(ServerFailure('No se puede eliminar')));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteAnnouncementRequested('ann-1')),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementError('No se puede eliminar'),
      ],
    );
  });

  group('US14 - Announcement detail', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'should emit [DetailLoaded] when fetching an announcement by ID',
      build: () {
        when(mockGetAnnouncementById('ann-1'))
            .thenAnswer((_) async => const Right(tAnnouncement));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAnnouncementById('ann-1')),
      expect: () => [
        const AnnouncementDetailLoaded(tAnnouncement),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'should not emit an error when fetching by ID fails (keeps route data)',
      build: () {
        when(mockGetAnnouncementById('ann-1'))
            .thenAnswer((_) async => const Left(ServerFailure('No encontrado')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAnnouncementById('ann-1')),
      expect: () => [],
    );
  });

  group('US10 - Filter announcements by creator', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'should filter announcements by creator',
      build: () {
        when(mockGetByCreator('user-1'))
            .thenAnswer((_) async => const Right([tAnnouncement]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAnnouncementsByCreator('user-1')),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementLoaded([tAnnouncement]),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'should load all when the creator is null',
      build: () {
        when(mockGetAnnouncements())
            .thenAnswer((_) async => const Right([tAnnouncement]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAnnouncementsByCreator(null)),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementLoaded([tAnnouncement]),
      ],
    );
  });
}
