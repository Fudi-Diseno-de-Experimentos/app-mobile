import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_bloc.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_event.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_state.dart';

import '../../../../mocks/generate_mocks.mocks.dart';
import '../../../../mocks/mock_helpers.dart';

void main() {
  late MockCreateCompanyUseCase mockCreate;
  late MockUpdateCompanyUseCase mockUpdate;
  late MockGetCompanyByUserIdUseCase mockGetByUserId;
  late CompanyBloc bloc;

  const tCompany = CompanyEntity(
    id: 'comp-1',
    ruc: '20123456789',
    nombre: 'Empresa Test SAC',
    iconUrl: 'logo.png',
    isActive: true,
    userId: 'user-1',
    joinCode: 'ABC123',
  );

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockCreate = MockCreateCompanyUseCase();
    mockUpdate = MockUpdateCompanyUseCase();
    mockGetByUserId = MockGetCompanyByUserIdUseCase();
    bloc = CompanyBloc(
      createCompanyUseCase: mockCreate,
      updateCompanyUseCase: mockUpdate,
      getCompanyByUserIdUseCase: mockGetByUserId,
    );
  });

  tearDown(() => bloc.close());

  group('US41 - Registro de nueva compañía', () {
    blocTest<CompanyBloc, CompanyState>(
      'debe emitir [Loading, CreateSuccess] al registrar compañía exitosamente',
      build: () {
        when(mockCreate(
          ruc: anyNamed('ruc'),
          nombre: anyNamed('nombre'),
          iconUrl: anyNamed('iconUrl'),
          isActive: anyNamed('isActive'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => const Right(tCompany));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateCompanyRequested(
        ruc: '20123456789',
        nombre: 'Empresa Test SAC',
        iconUrl: 'logo.png',
        isActive: true,
        userId: 'user-1',
      )),
      expect: () => [
        CompanyLoading(),
        const CompanyCreateSuccess(tCompany),
      ],
    );

    blocTest<CompanyBloc, CompanyState>(
      'debe emitir [Loading, Failure] cuando el RUC ya está registrado',
      build: () {
        when(mockCreate(
          ruc: anyNamed('ruc'),
          nombre: anyNamed('nombre'),
          iconUrl: anyNamed('iconUrl'),
          isActive: anyNamed('isActive'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => const Left(ServerFailure('La organización ya existe')));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateCompanyRequested(
        ruc: '20123456789',
        nombre: 'Duplicada',
        isActive: true,
        userId: 'user-1',
      )),
      expect: () => [
        CompanyLoading(),
        const CompanyFailure('La organización ya existe'),
      ],
    );
  });

  group('US42 - Edición de perfil de compañía', () {
    blocTest<CompanyBloc, CompanyState>(
      'debe emitir [Loading, UpdateSuccess] al actualizar compañía exitosamente',
      build: () {
        const updated = CompanyEntity(
          id: 'comp-1',
          ruc: '20123456789',
          nombre: 'Empresa Actualizada SAC',
          iconUrl: 'new_logo.png',
          isActive: true,
          userId: 'user-1',
          joinCode: 'ABC123',
        );
        when(mockUpdate(
          id: anyNamed('id'),
          ruc: anyNamed('ruc'),
          nombre: anyNamed('nombre'),
          iconUrl: anyNamed('iconUrl'),
          isActive: anyNamed('isActive'),
        )).thenAnswer((_) async => const Right(updated));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateCompanyRequested(
        id: 'comp-1',
        ruc: '20123456789',
        nombre: 'Empresa Actualizada SAC',
        iconUrl: 'new_logo.png',
        isActive: true,
      )),
      expect: () => [
        CompanyLoading(),
        isA<CompanyUpdateSuccess>(),
      ],
    );

    blocTest<CompanyBloc, CompanyState>(
      'debe emitir [Loading, Failure] cuando falla la actualización',
      build: () {
        when(mockUpdate(
          id: anyNamed('id'),
          ruc: anyNamed('ruc'),
          nombre: anyNamed('nombre'),
          iconUrl: anyNamed('iconUrl'),
          isActive: anyNamed('isActive'),
        )).thenAnswer((_) async => const Left(ServerFailure('Error de servidor')));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateCompanyRequested(
        id: 'comp-1',
        ruc: '20123456789',
        nombre: 'Test',
        isActive: true,
      )),
      expect: () => [
        CompanyLoading(),
        const CompanyFailure('Error de servidor'),
      ],
    );
  });

  group('US41 - Obtener compañía del usuario', () {
    blocTest<CompanyBloc, CompanyState>(
      'debe emitir [Loading, LoadSuccess] al obtener compañía por userId',
      build: () {
        when(mockGetByUserId('user-1'))
            .thenAnswer((_) async => const Right(tCompany));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetCompanyRequested('user-1')),
      expect: () => [
        CompanyLoading(),
        const CompanyLoadSuccess(tCompany),
      ],
    );

    blocTest<CompanyBloc, CompanyState>(
      'debe emitir [Loading, Failure] cuando el usuario no tiene compañía',
      build: () {
        when(mockGetByUserId('user-sin-company'))
            .thenAnswer((_) async => const Left(ServerFailure('Compañía no encontrada')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetCompanyRequested('user-sin-company')),
      expect: () => [
        CompanyLoading(),
        const CompanyFailure('Compañía no encontrada'),
      ],
    );
  });
}
