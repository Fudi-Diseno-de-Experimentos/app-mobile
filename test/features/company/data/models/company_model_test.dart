import 'package:app_mobile/features/company/data/models/company_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompanyModel - US41: New company registration', () {
    test('fromJson should build a valid model with all fields', () {
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
      expect(model.name, 'Empresa Test SAC');
      expect(model.iconUrl, 'https://example.com/logo.png');
      expect(model.isActive, true);
      expect(model.userId, 'user-1');
      expect(model.joinCode, 'ABC123');
    });

    test('fromJson should handle a null iconUrl', () {
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

    test('fromJson should default joinCode to empty when missing from the JSON', () {
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

    test('toJson should produce a valid map for the API', () {
      // Arrange
      const model = CompanyModel(
        id: 'comp-1',
        ruc: '20123456789',
        name: 'Empresa Test',
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

    test('toJson/fromJson should be symmetric (roundtrip)', () {
      // Arrange
      const original = CompanyModel(
        id: 'comp-1',
        ruc: '20123456789',
        name: 'Roundtrip SAC',
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

  group('CompanyModel - US43: Company service deactivation', () {
    test('fromJson should parse isActive false for a deactivated company', () {
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
