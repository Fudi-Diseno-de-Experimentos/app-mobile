import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile/features/announcements/data/models/comment_model.dart';

void main() {
  group('CommentModel - US15: Comentarios en anuncios', () {
    test('fromJson debe crear un modelo válido con todos los campos', () {
      // Arrange
      final json = {
        'id': 'comment-1',
        'announcementId': 'ann-1',
        'content': 'Tengo una duda sobre esta política',
        'employeeId': 'emp-1',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      // Act
      final model = CommentModel.fromJson(json);

      // Assert
      expect(model.id, 'comment-1');
      expect(model.announcementId, 'ann-1');
      expect(model.content, 'Tengo una duda sobre esta política');
      expect(model.authorId, 'emp-1');
      expect(model.createdAt, '2024-01-01T00:00:00Z');
    });

    test('fromJson debe mapear employeeId del API a authorId del dominio', () {
      // Arrange
      final json = {
        'id': '1',
        'announcementId': 'ann-1',
        'content': 'Comentario',
        'employeeId': 'emp-42',
        'createdAt': '',
        'updatedAt': '',
      };

      // Act
      final model = CommentModel.fromJson(json);

      // Assert
      expect(model.authorId, 'emp-42');
    });

    test('fromJson debe manejar campos faltantes con valores por defecto', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final model = CommentModel.fromJson(json);

      // Assert
      expect(model.id, '');
      expect(model.announcementId, '');
      expect(model.content, '');
      expect(model.authorId, '');
    });

    test('fromJson debe convertir IDs numéricos a String', () {
      // Arrange
      final json = {
        'id': 123,
        'announcementId': 456,
        'content': 'Contenido',
        'employeeId': 789,
        'createdAt': '2024-01-01',
        'updatedAt': '2024-01-01',
      };

      // Act
      final model = CommentModel.fromJson(json);

      // Assert
      expect(model.id, '123');
      expect(model.announcementId, '456');
      expect(model.authorId, '789');
    });
  });
}
