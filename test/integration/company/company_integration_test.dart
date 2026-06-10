import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/features/company/data/models/company_model.dart';
import 'package:app_mobile/features/company/data/repositories/company_repository_impl.dart';
import 'package:app_mobile/features/company/domain/usecases/create_company_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/update_company_usecase.dart';
import 'package:app_mobile/features/company/domain/usecases/get_company_by_user_id_usecase.dart';

import '../../mocks/generate_mocks.mocks.dart';

void main() {
  late MockCompanyRemoteDataSource mockDataSource;
  late CompanyRepositoryImpl repository;

  const tCompanyModel = CompanyModel(
    id: 'comp-1',
    ruc: '20123456789',
    nombre: 'Empresa SAC',
    iconUrl: 'logo.png',
    isActive: true,
    userId: 'user-1',
    joinCode: 'ABC123',
  );

  setUp(() {
    mockDataSource = MockCompanyRemoteDataSource();
    repository = CompanyRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('US41 - Integración: Registro de nueva compañía', () {
    test('debe crear compañía pasando por todas las capas', () async {
      // Arrange
      when(mockDataSource.createCompany(
        ruc: anyNamed('ruc'),
        nombre: anyNamed('nombre'),
        iconUrl: anyNamed('iconUrl'),
        isActive: anyNamed('isActive'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async => tCompanyModel);
      final useCase = CreateCompanyUseCase(repository);

      // Act
      final result = await useCase(
        ruc: '20123456789',
        nombre: 'Empresa SAC',
        iconUrl: 'logo.png',
        isActive: true,
        userId: 'user-1',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Debería ser Right'),
        (company) {
          expect(company.ruc, '20123456789');
          expect(company.nombre, 'Empresa SAC');
          expect(company.joinCode, 'ABC123');
        },
      );
    });

    test('debe retornar ServerFailure cuando el RUC ya existe', () async {
      // Arrange
      when(mockDataSource.createCompany(
        ruc: anyNamed('ruc'),
        nombre: anyNamed('nombre'),
        iconUrl: anyNamed('iconUrl'),
        isActive: anyNamed('isActive'),
        userId: anyNamed('userId'),
      )).thenThrow(ServerException(message: 'RUC already registered'));
      final useCase = CreateCompanyUseCase(repository);

      // Act
      final result = await useCase(
        ruc: '20123456789',
        nombre: 'Duplicada',
        isActive: true,
        userId: 'user-1',
      );

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('US42 - Integración: Edición de perfil de compañía', () {
    test('debe actualizar compañía pasando por todas las capas', () async {
      // Arrange
      const updatedModel = CompanyModel(
        id: 'comp-1',
        ruc: '20123456789',
        nombre: 'Empresa Actualizada',
        iconUrl: 'new_logo.png',
        isActive: true,
        userId: 'user-1',
        joinCode: 'ABC123',
      );
      when(mockDataSource.updateCompany(
        id: anyNamed('id'),
        ruc: anyNamed('ruc'),
        nombre: anyNamed('nombre'),
        iconUrl: anyNamed('iconUrl'),
        isActive: anyNamed('isActive'),
      )).thenAnswer((_) async => updatedModel);
      final useCase = UpdateCompanyUseCase(repository);

      // Act
      final result = await useCase(
        id: 'comp-1',
        ruc: '20123456789',
        nombre: 'Empresa Actualizada',
        iconUrl: 'new_logo.png',
        isActive: true,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Debería ser Right'),
        (company) => expect(company.nombre, 'Empresa Actualizada'),
      );
    });
  });

  group('US41 - Integración: Obtener compañía del usuario', () {
    test('debe obtener compañía por userId pasando por todas las capas', () async {
      // Arrange
      when(mockDataSource.getCompanyByUserId('user-1'))
          .thenAnswer((_) async => tCompanyModel);
      final useCase = GetCompanyByUserIdUseCase(repository);

      // Act
      final result = await useCase('user-1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Debería ser Right'),
        (company) {
          expect(company.id, 'comp-1');
          expect(company.userId, 'user-1');
        },
      );
    });

    test('debe retornar ServerFailure cuando el usuario no tiene compañía', () async {
      // Arrange
      when(mockDataSource.getCompanyByUserId('user-no-company'))
          .thenThrow(ServerException(message: 'Not found'));
      final useCase = GetCompanyByUserIdUseCase(repository);

      // Act
      final result = await useCase('user-no-company');

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
