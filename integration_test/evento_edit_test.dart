import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';

void main() {
  patrolTest('Crear evento e intentar editar desde el detalle', ($) async {
    await dotenv.load(fileName: ".env");
    await initDependencies();

    await $.pumpWidgetAndSettle(const MyApp());

    // 1. Login Real
    await $(TextFormField).at(0).enterText('adamin');
    await $(TextFormField).at(1).enterText('123456');
    await $('Sign in').tap();
    await $.pumpAndSettle();

    // 2. Navegar a Events
    await $('Files').tap();
    await $.pumpAndSettle();

    await $('Events').tap();
    await $.pumpAndSettle();

    // 3. Crear un evento para luego intentar editarlo
    await $(Icons.event).tap();
    await $.pumpAndSettle();

    expect($('New Event Details'), findsOneWidget);

    await $(TextFormField).at(0).enterText('Evento Para Editar');
    await $(TextFormField).at(1).scrollTo().enterText('Evento de prueba para verificar edicion.');

    await $(Icons.calendar_today).scrollTo().tap();
    await $.pumpAndSettle();
    await $('OK').tap();
    await $.pumpAndSettle();

    await $(Icons.access_time).scrollTo().tap();
    await $.pumpAndSettle();
    await $('OK').tap();
    await $.pumpAndSettle();

    await $(TextFormField).at(2).scrollTo().enterText('Auditorio B');

    FocusManager.instance.primaryFocus?.unfocus();
    await $.pumpAndSettle();

    await $(ElevatedButton).scrollTo().tap();
    await $.pumpAndSettle();

    expect($('Event created successfully!'), findsOneWidget);
    await $.pumpAndSettle();

    // 4. Volvemos a la lista y abrimos el evento recien creado
    await $('Evento Para Editar').tap();
    await $.pumpAndSettle();

    // 5. Abrir menu de opciones (solo visible para ROLE_ADMIN o creador)
    await $(Icons.more_vert).tap();
    await $.pumpAndSettle();

    // 6. Seleccionar Edit del popup menu
    await $('Edit').tap();
    await $.pumpAndSettle();

    // 7. Verificar que la opcion de edicion muestra el estado actual (coming soon)
    expect($('Edit coming soon'), findsOneWidget);
  });
}
