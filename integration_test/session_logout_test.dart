import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'helpers/mock_test_helpers.dart';

/// US35 - Mantener la sesión iniciada
/// Como empleado, quiero mantener la sesión iniciada de forma segura
/// para no tener que volver a autenticarme con frecuencia.
///
/// US36 - Cierre de sesión seguro
/// Como empleado, quiero cerrar sesión de forma segura para que mi sesión
/// finalice por completo y no pueda ser reutilizada.
void main() {
  patrolTest(
    'US35/US36 - Sesión: debe iniciar sesión exitosamente y navegar al home',
    ($) async {
      // Arrange
      await dotenv.load(fileName: ".env");
      await initDependencies();
      setupAllMockDependencies();

      await $.pumpWidgetAndSettle(const MyApp());

      // Act - Iniciar sesión
      await $(TextFormField).at(0).enterText('testadmin');
      await $(TextFormField).at(1).enterText('123456');
      await $('Sign in').tap();
      await $.pumpAndSettle();

      // Assert - Verificar que llegamos al home
      expect($('Home'), findsOneWidget);
    },
  );

  patrolTest(
    'US36 - Cierre de sesión: debe cerrar sesión y redirigir al login',
    ($) async {
      // Arrange
      await dotenv.load(fileName: ".env");
      await initDependencies();
      setupAllMockDependencies();

      await $.pumpWidgetAndSettle(const MyApp());

      // Act - Login primero
      await $(TextFormField).at(0).enterText('testadmin');
      await $(TextFormField).at(1).enterText('123456');
      await $('Sign in').tap();
      await $.pumpAndSettle();

      // Navegar a Settings (perfil -> settings)
      await $('Profile').tap();
      await $.pumpAndSettle();

      await $(Icons.settings).tap();
      await $.pumpAndSettle();

      // Assert - Verificar que estamos en Settings
      expect($('Settings'), findsOneWidget);
      expect($('Sign Out'), findsOneWidget);

      // Act - Cerrar sesión
      await $('Sign Out').tap();
      await $.pumpAndSettle();

      // Assert - Verificar redirección al login
      expect($('Sign in'), findsOneWidget);
      expect($('User Name'), findsOneWidget);
    },
  );
}
