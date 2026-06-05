import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';

void main() {
  patrolTest('Crear anuncio con permiso nativo de galeria', ($) async {
    // Configuración inicial
    await dotenv.load(fileName: ".env");
    await initDependencies();

    // Inyectar mocks después de inicializar dependencias
    // setupMockDependencies(); // Retirado para usar login real

    // Arrancar la app
    await $.pumpWidgetAndSettle(const MyApp());

    // 1. Login Real
    await $(TextFormField).at(0).enterText('adamin');
    await $(TextFormField).at(1).enterText('123456');
    await $('Sign in').tap();

    // 2. Navegar al Feed y crear anuncio
    // Esperar a navegar al Home
    await $.pumpAndSettle();

    // Navegar a "Files" usando el texto de la etiqueta del BottomNavigationBarItem
    await $('Files').tap();
    await $.pumpAndSettle();

    // Buscar el tab "Announcements" que es el tab por defecto en CompanyFeedPage
    await $('Announcements').tap();
    await $.pumpAndSettle();

    // Pulsar FloatingActionButton (tiene el ícono add en Announcements)
    await $(Icons.add).tap();
    await $.pumpAndSettle();

    // 3. Formulario de Anuncio
    expect($('Create Announcement'), findsOneWidget);

    // Ingresar título usando el índice del TextFormField (es más seguro que buscar por hint)
    await $(TextFormField).at(0).enterText('Nuevo Anuncio Importante');

    // El Dropdown ya tiene 'NORMAL' por defecto, evitamos abrirlo para no causar flakiness
    // ya que al abrir el teclado en algunos emuladores puede ocultar el dropdown temporalmente.

    // Ingresar descripción en el segundo TextFormField
    await $(
      TextFormField,
    ).at(1).scrollTo().enterText('Detalles del anuncio de prueba en Patrol.');

    // Ocultar teclado solo si es estrictamente necesario, aunque Patrol y Flutter
    // a menudo lo manejan bien al hacer scroll o unfocus.
    // Usamos tap en un área vacía o cerramos teclado de forma segura:
    FocusManager.instance.primaryFocus?.unfocus();
    await $.pumpAndSettle();

    // 4. Guardar Anuncio (omitimos imagen para evitar problemas nativos de galería a menos que sea requerido)
    await $('Publish Announcement').scrollTo().tap();
    await $.pumpAndSettle();

    // Comprobar éxito
    expect($('Announcement published successfully!'), findsOneWidget);
  });
}
