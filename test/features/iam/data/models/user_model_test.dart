import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile/features/iam/data/models/user_model.dart';

void main() {
  group('UserModel - US38: Autenticación segura con JWT', () {
    test('fromJson debe crear un modelo válido con todos los campos', () {
      // Arrange
      final json = {
        'id': 'user-1',
        'username': 'admin',
        'token': 'eyJhbGciOiJIUzI1NiJ9.fake.token',
        'companyId': 'company-1',
      };

      // Act
      final model = UserModel.fromJson(json);

      // Assert
      expect(model.id, 'user-1');
      expect(model.username, 'admin');
      expect(model.token, 'eyJhbGciOiJIUzI1NiJ9.fake.token');
      expect(model.companyId, 'company-1');
    });

    test('fromJson debe manejar companyId nulo para usuarios sin compañía', () {
      // Arrange
      final json = {
        'id': 'user-2',
        'username': 'nuevo_empleado',
        'token': 'token-abc',
        'companyId': null,
      };

      // Act
      final model = UserModel.fromJson(json);

      // Assert
      expect(model.companyId, isNull);
    });

    test('fromJson debe convertir IDs numéricos a String', () {
      // Arrange
      final json = {
        'id': 42,
        'username': 'user',
        'token': 'token',
        'companyId': 99,
      };

      // Act
      final model = UserModel.fromJson(json);

      // Assert
      expect(model.id, '42');
      expect(model.companyId, '99');
    });

    test('fromJson debe manejar campos faltantes con valores por defecto', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final model = UserModel.fromJson(json);

      // Assert
      expect(model.id, '');
      expect(model.username, '');
      expect(model.token, '');
      expect(model.companyId, isNull);
    });
  });
}
