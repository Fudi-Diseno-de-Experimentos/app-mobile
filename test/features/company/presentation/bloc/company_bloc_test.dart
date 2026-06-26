import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_bloc.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_event.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

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
    name: 'Empresa Test SAC',
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

  group('US41 - New company registration', () {
    blocTest<CompanyBloc, CompanyState>(
      'should emit [Loading, CreateSuccess] when a company is registered successfully',
      build: () {
        when(mockCreate(
          ruc: anyNamed('ruc'),
          name: anyNamed('name'),
          iconUrl: anyNamed('iconUrl'),
          isActive: anyNamed('isActive'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => const Right(tCompany));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateCompanyRequested(
        ruc: '20123456789',
        name: 'Empresa Test SAC',
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
      'should emit [Loading, Failure] when the RUC is already registered',
      build: () {
        when(mockCreate(
          ruc: anyNamed('ruc'),
          name: anyNamed('name'),
          iconUrl: anyNamed('iconUrl'),
          isActive: anyNamed('isActive'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => const Left(ServerFailure('The organization already exists')));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateCompanyRequested(
        ruc: '20123456789',
        name: 'Duplicada',
        isActive: true,
        userId: 'user-1',
      )),
      expect: () => [
        CompanyLoading(),
        const CompanyFailure('The organization already exists'),
      ],
    );
  });

  group('US42 - Company profile editing', () {
    blocTest<CompanyBloc, CompanyState>(
      'should emit [Loading, UpdateSuccess] when the company updates successfully',
      build: () {
        const updated = CompanyEntity(
          id: 'comp-1',
          ruc: '20123456789',
          name: 'Empresa Actualizada SAC',
          iconUrl: 'new_logo.png',
          isActive: true,
          userId: 'user-1',
          joinCode: 'ABC123',
        );
        when(mockUpdate(
          id: anyNamed('id'),
          ruc: anyNamed('ruc'),
          name: anyNamed('name'),
          iconUrl: anyNamed('iconUrl'),
          isActive: anyNamed('isActive'),
        )).thenAnswer((_) async => const Right(updated));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateCompanyRequested(
        id: 'comp-1',
        ruc: '20123456789',
        name: 'Empresa Actualizada SAC',
        iconUrl: 'new_logo.png',
        isActive: true,
      )),
      expect: () => [
        CompanyLoading(),
        isA<CompanyUpdateSuccess>(),
      ],
    );

    blocTest<CompanyBloc, CompanyState>(
      'should emit [Loading, Failure] when the update fails',
      build: () {
        when(mockUpdate(
          id: anyNamed('id'),
          ruc: anyNamed('ruc'),
          name: anyNamed('name'),
          iconUrl: anyNamed('iconUrl'),
          isActive: anyNamed('isActive'),
        )).thenAnswer((_) async => const Left(ServerFailure('Error de servidor')));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateCompanyRequested(
        id: 'comp-1',
        ruc: '20123456789',
        name: 'Test',
        isActive: true,
      )),
      expect: () => [
        CompanyLoading(),
        const CompanyFailure('Error de servidor'),
      ],
    );
  });

  group('US41 - Fetch the user company', () {
    blocTest<CompanyBloc, CompanyState>(
      'should emit [Loading, LoadSuccess] when fetching the company by userId',
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
      'should emit [Loading, Failure] when the user has no company',
      build: () {
        when(mockGetByUserId('user-sin-company'))
            .thenAnswer((_) async => const Left(ServerFailure('Company not found')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetCompanyRequested('user-sin-company')),
      expect: () => [
        CompanyLoading(),
        const CompanyFailure('Company not found'),
      ],
    );
  });
}
