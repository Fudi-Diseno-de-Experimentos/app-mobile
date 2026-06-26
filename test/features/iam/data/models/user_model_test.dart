import 'package:app_mobile/features/iam/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel - US38: Secure JWT authentication', () {
    test('fromJson should build a valid model with all fields', () {
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

    test('fromJson should handle a null companyId for users without a company', () {
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

    test('fromJson should convert numeric IDs to String', () {
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

    test('fromJson should handle missing fields with defaults', () {
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
