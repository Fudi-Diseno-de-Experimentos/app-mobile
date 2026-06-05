import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_state.dart';

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
    title: 'Anuncio Test',
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

  group('US10 - Publicación básica de anuncios', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'debe emitir [Loading, Loaded] cuando se obtienen anuncios exitosamente',
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
      'debe emitir [Loading, Error] cuando falla la obtención de anuncios',
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
      'debe emitir [Loading, CreateSuccess, Loading, Loaded] al crear un anuncio exitosamente',
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
        title: 'Anuncio Test',
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
      'debe emitir [Loading, Error] cuando falla la creación de un anuncio',
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

  group('US11 - Priorización de anuncios', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'debe filtrar anuncios por prioridad HIGH',
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
      'debe cargar todos los anuncios cuando la prioridad es nula',
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
      'debe cargar todos los anuncios cuando la prioridad es cadena vacía',
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

  group('US12 - Edición de anuncios', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'debe emitir [Loading, UpdateSuccess] al actualizar un anuncio exitosamente',
      build: () {
        const updated = AnnouncementEntity(
          id: 'ann-1',
          title: 'Título Actualizado',
          description: 'Nueva descripción',
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
        title: 'Título Actualizado',
        description: 'Nueva descripción',
        priority: 'HIGH',
      )),
      expect: () => [
        AnnouncementLoading(),
        isA<AnnouncementUpdateSuccess>(),
      ],
    );
  });

  group('US13 - Eliminación de anuncios', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'debe emitir [Loading, DeleteSuccess] al eliminar un anuncio exitosamente',
      build: () {
        when(mockDelete('ann-1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteAnnouncementRequested('ann-1')),
      expect: () => [
        AnnouncementLoading(),
        const AnnouncementDeleteSuccess('ann-1'),
      ],
    );

    blocTest<AnnouncementBloc, AnnouncementState>(
      'debe emitir [Loading, Error] cuando falla la eliminación',
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

  group('US14 - Detalle de anuncio', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'debe emitir [DetailLoaded] al obtener un anuncio por ID',
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
      'no debe emitir error cuando falla la obtención por ID (mantiene datos de ruta)',
      build: () {
        when(mockGetAnnouncementById('ann-1'))
            .thenAnswer((_) async => const Left(ServerFailure('No encontrado')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAnnouncementById('ann-1')),
      expect: () => [],
    );
  });

  group('US10 - Filtrar anuncios por creador', () {
    blocTest<AnnouncementBloc, AnnouncementState>(
      'debe filtrar anuncios por creador',
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
      'debe cargar todos cuando el creador es nulo',
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
