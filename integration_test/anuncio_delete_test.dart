import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'helpers/mock_test_helpers.dart';

/// US13 - Eliminación de anuncios
/// Como gerente, quiero eliminar anuncios obsoletos para mantener
/// la información actualizada.
void main() {
  patrolTest(
    'US13 - Eliminación de anuncios: debe eliminar un anuncio y confirmar la acción',
    ($) async {
      // Arrange - Configuración inicial con mocks
      await dotenv.load(fileName: ".env");
      await initDependencies();
      setupAllMockDependencies();
      await sl<SharedPreferences>().remove('auth_token');

      await $.pumpWidgetAndSettle(const MyApp());

      // Act - Login con datos mock
      await $(TextFormField).at(0).enterText('testadmin');
      await $(TextFormField).at(1).enterText('123456');
      await $('Sign in').tap();
      await $.pumpAndSettle();

      // Navegar al Feed de anuncios (Announcements ya está seleccionado por defecto)
      await $('Files').tap();
      await $.pumpAndSettle();

      // Assert - Verificar que el anuncio existe
      expect($('Anuncio de Prueba'), findsOneWidget);

      // Act - Abrir el detalle del anuncio
      await $('Anuncio de Prueba').tap();
      await $.pumpAndSettle();

      // Abrir menú de opciones
      await $(Icons.more_vert).tap();
      await $.pumpAndSettle();

      // Seleccionar Delete del PopupMenu
      await $('Delete').tap();
      await $.pumpAndSettle();

      // Confirmar la eliminación en el AlertDialog
      expect($('Delete Announcement'), findsOneWidget);
      await $(AlertDialog).$(TextButton).last.tap();
      await $.pumpAndSettle();

      // Assert - Verificar snackbar de éxito
      expect($('Announcement deleted'), findsOneWidget);
    },
  );
}
