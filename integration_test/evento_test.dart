import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'helpers/mock_test_helpers.dart';

/// US18 - Creación básica de eventos
/// Como gerente, quiero crear eventos en la aplicación móvil para organizar
/// reuniones y actividades de la empresa.
void main() {
  patrolTest(
    'US18 - Creación de eventos: debe navegar al formulario de creación de eventos',
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

      // Navegar al Feed y cambiar al tab Events
      await $('Files').tap();
      await $.pumpAndSettle();

      await $('Events').tap();
      await $.pumpAndSettle();

      // Assert - Verificar que los eventos mock se muestran
      expect($('Evento de Prueba'), findsOneWidget);

      // Act - Tap FAB para crear evento (solo visible para ROLE_ADMIN/ROLE_MANAGER)
      await $(Icons.event).tap();
      await $.pumpAndSettle();

      // Assert - Verificar que se muestra el formulario de creación
      expect($('Create Event'), findsOneWidget);
      expect($('New Event Details'), findsOneWidget);
    },
  );
}
