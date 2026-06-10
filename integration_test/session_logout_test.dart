import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    'US35/US36 - Sesión: debe iniciar sesión, navegar al home, cerrar sesión y redirigir al login',
    ($) async {
      // Arrange
      await dotenv.load(fileName: ".env");
      await initDependencies();
      setupAllMockDependencies();
      await sl<SharedPreferences>().remove('auth_token');

      await $.pumpWidgetAndSettle(const MyApp());

      // === US35: Iniciar sesión exitosamente ===

      // Act - Iniciar sesión
      await $(TextFormField).at(0).enterText('testadmin');
      await $(TextFormField).at(1).enterText('123456');
      await $('Sign in').tap();
      await $.pumpAndSettle();

      // Assert - Verificar que llegamos al home
      expect($('Home'), findsWidgets);

      // === US36: Cerrar sesión y redirigir al login ===

      // Act - Navegar a Profile
      await $('Profile').tap();
      await $.pumpAndSettle();

      // Act - Abrir Settings (el ícono es settings_outlined)
      await $(Icons.settings_outlined).tap();
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
