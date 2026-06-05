import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile/features/profile/data/models/profile_model.dart';

void main() {
  group('ProfileModel - US39: Navegación basada en roles', () {
    test('fromJson debe crear un modelo válido con todos los campos', () {
      // Arrange
      final json = {
        'profileId': 'profile-1',
        'userId': 'user-1',
        'username': 'jperez',
        'firstName': 'Juan',
        'lastName': 'Pérez',
        'email': 'juan@empresa.com',
        'roles': ['ROLE_USER', 'ROLE_MANAGER'],
        'companyId': 'comp-1',
        'avatarUrl': 'https://example.com/avatar.png',
      };

      // Act
      final model = ProfileModel.fromJson(json);

      // Assert
      expect(model.id, 'profile-1');
      expect(model.userId, 'user-1');
      expect(model.username, 'jperez');
      expect(model.name, 'Juan');
      expect(model.lastname, 'Pérez');
      expect(model.email, 'juan@empresa.com');
      expect(model.roles, ['ROLE_USER', 'ROLE_MANAGER']);
      expect(model.companyId, 'comp-1');
      expect(model.avatarUrl, 'https://example.com/avatar.png');
    });

    test('fromJson debe usar campo id como fallback si profileId no existe', () {
      // Arrange
      final json = {
        'id': 'fallback-id',
        'username': 'user',
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@test.com',
      };

      // Act
      final model = ProfileModel.fromJson(json);

      // Assert
      expect(model.id, 'fallback-id');
    });

    test('fromJson debe usar name/lastname como fallback de firstName/lastName', () {
      // Arrange
      final json = {
        'id': '1',
        'username': 'user',
        'name': 'FallbackName',
        'lastname': 'FallbackLastname',
        'email': 'test@test.com',
      };

      // Act
      final model = ProfileModel.fromJson(json);

      // Assert
      expect(model.name, 'FallbackName');
      expect(model.lastname, 'FallbackLastname');
    });

    test('fromJson debe manejar roles nulos como lista vacía', () {
      // Arrange
      final json = {
        'id': '1',
        'username': 'user',
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@test.com',
        'roles': null,
      };

      // Act
      final model = ProfileModel.fromJson(json);

      // Assert
      expect(model.roles, isEmpty);
    });

    test('fromJson debe parsear roles de administrador correctamente', () {
      // Arrange
      final json = {
        'profileId': '1',
        'username': 'admin',
        'firstName': 'Admin',
        'lastName': 'User',
        'email': 'admin@test.com',
        'roles': ['ROLE_ADMIN', 'ROLE_MANAGER', 'ROLE_USER'],
      };

      // Act
      final model = ProfileModel.fromJson(json);

      // Assert
      expect(model.roles, contains('ROLE_ADMIN'));
      expect(model.roles, contains('ROLE_MANAGER'));
      expect(model.roles!.length, 3);
    });

    test('toJson debe generar el formato esperado por el API de actualización', () {
      // Arrange
      const model = ProfileModel(
        id: '1',
        userId: 'u1',
        username: 'jperez',
        name: 'Juan',
        lastname: 'Pérez',
        email: 'juan@test.com',
        avatarUrl: 'avatar.png',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['firstName'], 'Juan');
      expect(json['lastName'], 'Pérez');
      expect(json['email'], 'juan@test.com');
      expect(json['avatarUrl'], 'avatar.png');
      expect(json.containsKey('id'), false);
      expect(json.containsKey('username'), false);
    });

    test('toCacheJson debe incluir todos los campos para persistencia local', () {
      // Arrange
      const model = ProfileModel(
        id: '1',
        userId: 'u1',
        username: 'jperez',
        name: 'Juan',
        lastname: 'Pérez',
        email: 'juan@test.com',
        roles: ['ROLE_USER'],
        companyId: 'comp-1',
        avatarUrl: 'avatar.png',
      );

      // Act
      final json = model.toCacheJson();

      // Assert
      expect(json['id'], '1');
      expect(json['userId'], 'u1');
      expect(json['username'], 'jperez');
      expect(json['name'], 'Juan');
      expect(json['roles'], ['ROLE_USER']);
      expect(json['companyId'], 'comp-1');
    });
  });
}
