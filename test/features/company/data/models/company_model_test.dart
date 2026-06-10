import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile/features/company/data/models/company_model.dart';

void main() {
  group('CompanyModel - US41: Registro de nueva compañía', () {
    test('fromJson debe crear un modelo válido con todos los campos', () {
      // Arrange
      final json = {
        'id': 'comp-1',
        'ruc': '20123456789',
        'nombre': 'Empresa Test SAC',
        'iconUrl': 'https://example.com/logo.png',
        'isActive': true,
        'userId': 'user-1',
        'joinCode': 'ABC123',
      };

      // Act
      final model = CompanyModel.fromJson(json);

      // Assert
      expect(model.id, 'comp-1');
      expect(model.ruc, '20123456789');
      expect(model.nombre, 'Empresa Test SAC');
      expect(model.iconUrl, 'https://example.com/logo.png');
      expect(model.isActive, true);
      expect(model.userId, 'user-1');
      expect(model.joinCode, 'ABC123');
    });

    test('fromJson debe manejar iconUrl nulo', () {
      // Arrange
      final json = {
        'id': 'comp-2',
        'ruc': '20987654321',
        'nombre': 'Sin Logo SRL',
        'iconUrl': null,
        'isActive': true,
        'userId': 'user-2',
        'joinCode': 'XYZ789',
      };

      // Act
      final model = CompanyModel.fromJson(json);

      // Assert
      expect(model.iconUrl, isNull);
    });

    test('fromJson debe asignar joinCode vacío cuando falta en el JSON', () {
      // Arrange
      final json = {
        'id': 'comp-3',
        'ruc': '20111111111',
        'nombre': 'Test',
        'iconUrl': null,
        'isActive': true,
        'userId': 'user-3',
      };

      // Act
      final model = CompanyModel.fromJson(json);

      // Assert
      expect(model.joinCode, '');
    });

    test('toJson debe generar un mapa válido para el API', () {
      // Arrange
      const model = CompanyModel(
        id: 'comp-1',
        ruc: '20123456789',
        nombre: 'Empresa Test',
        iconUrl: 'logo.png',
        isActive: true,
        userId: 'user-1',
        joinCode: 'ABC',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 'comp-1');
      expect(json['ruc'], '20123456789');
      expect(json['nombre'], 'Empresa Test');
      expect(json['isActive'], true);
      expect(json['userId'], 'user-1');
    });

    test('toJson/fromJson debe ser simétrico (roundtrip)', () {
      // Arrange
      const original = CompanyModel(
        id: 'comp-1',
        ruc: '20123456789',
        nombre: 'Roundtrip SAC',
        iconUrl: 'logo.png',
        isActive: true,
        userId: 'user-1',
        joinCode: 'ABC123',
      );

      // Act
      final json = original.toJson();
      final restored = CompanyModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
    });
  });

  group('CompanyModel - US43: Baja del servicio de compañía', () {
    test('fromJson debe parsear isActive false para compañía dada de baja', () {
      // Arrange
      final json = {
        'id': 'comp-inactive',
        'ruc': '20999999999',
        'nombre': 'Empresa Inactiva',
        'iconUrl': null,
        'isActive': false,
        'userId': 'user-1',
        'joinCode': '',
      };

      // Act
      final model = CompanyModel.fromJson(json);

      // Assert
      expect(model.isActive, false);
    });
  });
}
