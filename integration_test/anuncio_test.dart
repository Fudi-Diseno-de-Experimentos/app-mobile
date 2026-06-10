import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'helpers/mock_test_helpers.dart';

/// US10 - Publicación básica de anuncios
/// Como gerente, quiero publicar anuncios en la aplicación móvil para que
/// los empleados estén informados de las novedades de la empresa.
void main() {
  patrolTest(
    'US10 - Publicación de anuncios: debe crear un anuncio exitosamente',
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

      // Tap FAB para crear anuncio
      await $(Icons.add).tap();
      await $.pumpAndSettle();

      // Assert - Verificar que estamos en la página de creación
      expect($('Create Announcement'), findsOneWidget);
      expect($('New Announcement'), findsOneWidget);

      // Act - Llenar formulario (título y descripción)
      await $(TextFormField).at(0).enterText('Nuevo Anuncio de Prueba');
      await $(TextFormField).at(1).scrollTo().enterText('Descripción del anuncio para pruebas patrol.');

      // Tap Publish Announcement
      await $('Publish Announcement').scrollTo().tap();
      await $.pumpAndSettle();

      // Assert - Verificar snackbar de éxito
      expect($('Announcement published successfully!'), findsOneWidget);
    },
  );
}
