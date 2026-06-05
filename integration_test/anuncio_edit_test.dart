import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'helpers/mock_test_helpers.dart';

/// US12 - Edición de anuncios
/// Como gerente, quiero editar anuncios ya publicados para corregir errores
/// o actualizar información.
void main() {
  patrolTest(
    'US12 - Edición de anuncios: debe permitir editar un anuncio existente',
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

      // Assert - Verificar que los anuncios mock se muestran
      expect($('Anuncio de Prueba'), findsOneWidget);

      // Act - Abrir el detalle del anuncio
      await $('Anuncio de Prueba').tap();
      await $.pumpAndSettle();

      // Abrir menú de opciones
      await $(Icons.more_vert).tap();
      await $.pumpAndSettle();

      // Seleccionar Edit del PopupMenu
      await $('Edit').tap();
      await $.pumpAndSettle();

      // Assert - Verificar que se muestra la pantalla de edición
      // 'Edit Announcement' aparece en el AppBar y como encabezado de la página
      expect($('Edit Announcement'), findsWidgets);
    },
  );
}
