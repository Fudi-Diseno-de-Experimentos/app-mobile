import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'helpers/test_helpers.dart';

void main() {
  patrolTest('Crear evento y verificar validacion', ($) async {
    // Configuración inicial
    await dotenv.load(fileName: ".env");
    await initDependencies();

    // Inyectar mocks
    // setupMockDependencies(); // Retirado para usar login real

    // Arrancar la app
    await $.pumpWidgetAndSettle(const MyApp());

    // 1. Login Real
    await $(TextFormField).at(0).enterText('adamin');
    await $(TextFormField).at(1).enterText('123456');
    await $('Sign in').tap();

    // 2. Navegar al Feed y crear evento
    await $.pumpAndSettle();

    // Navegar a "Files" usando el texto del BottomNavigationBarItem
    await $('Files').tap();
    await $.pumpAndSettle();

    // Cambiar al tab de eventos
    await $('Events').tap();
    await $.pumpAndSettle();

    // El FAB de crear evento solo es visible para ROLE_ADMIN/MANAGER
    await $(Icons.event).tap();
    await $.pumpAndSettle();

    // 3. Llenar Formulario
    // Buscamos un texto único en la pantalla para validar que cargó el formulario
    expect($('New Event Details'), findsOneWidget);

    // Ingresar título en el primer TextFormField
    await $(TextFormField).at(0).enterText('Reunión Anual Test');

    // Ingresar descripción en el segundo TextFormField
    await $(
      TextFormField,
    ).at(1).scrollTo().enterText('Este es un evento de integración.');

    // Seleccionar fecha
    await $(Icons.calendar_today).scrollTo().tap();
    await $.pumpAndSettle();
    await $('OK').tap(); // Material DatePicker OK button
    await $.pumpAndSettle();

    // Seleccionar hora
    await $(Icons.access_time).scrollTo().tap();
    await $.pumpAndSettle();
    await $('OK').tap(); // Material TimePicker OK button
    await $.pumpAndSettle();

    // Ubicación en el tercer TextFormField
    await $(TextFormField).at(2).scrollTo().enterText('Auditorio Principal');

    // Ocultar el teclado de forma segura
    FocusManager.instance.primaryFocus?.unfocus();
    await $.pumpAndSettle();

    // Seleccionar al primer miembro disponible en la lista (si existe)
    try {
      await $(CheckboxListTile).first.scrollTo().tap();
    } catch (_) {
      // Si no hay miembros disponibles, no fallamos
    }

    // 4. Guardar evento
    // Buscamos directamente el ElevatedButton en lugar de buscar por texto,
    // lo cual es mucho más seguro para hacer scroll al final de la pantalla.
    await $(ElevatedButton).scrollTo().tap();
    await $.pumpAndSettle();

    // Verificar Snackbar de éxito
    expect($('Event created successfully!'), findsOneWidget);
  });
}
