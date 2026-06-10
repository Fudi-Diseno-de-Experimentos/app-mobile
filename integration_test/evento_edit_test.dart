import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'helpers/mock_test_helpers.dart';

/// US20 - Modificación de eventos
/// Como gerente, quiero modificar detalles de eventos existentes
/// para ajustar cambios de último momento.
void main() {
  patrolTest(
    'US20 - Modificación de eventos: debe permitir editar un evento existente',
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

      // Assert - Verificar que el evento mock se muestra
      expect($('Evento de Prueba'), findsOneWidget);

      // Act - Abrir el detalle del evento
      await $('Evento de Prueba').tap();
      await $.pumpAndSettle();

      // Abrir menú de opciones
      await $(Icons.more_vert).tap();
      await $.pumpAndSettle();

      // Seleccionar Edit del PopupMenu
      await $('Edit').tap();
      await $.pumpAndSettle();

      // Assert - Verificar que se muestra la pantalla de edición
      expect($('Edit Event'), findsOneWidget);
    },
  );
}
