import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';

void main() {
  patrolTest('Crear evento y eliminarlo desde el detalle', ($) async {
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

    // 3. Crear el evento que luego eliminaremos
    await $(Icons.event).tap();
    await $.pumpAndSettle();

    expect($('New Event Details'), findsOneWidget);

    await $(TextFormField).at(0).enterText('Evento Para Eliminar');
    await $(TextFormField).at(1).scrollTo().enterText('Evento de prueba para verificar eliminacion.');

    await $(Icons.calendar_today).scrollTo().tap();
    await $.pumpAndSettle();
    await $('OK').tap();
    await $.pumpAndSettle();

    await $(Icons.access_time).scrollTo().tap();
    await $.pumpAndSettle();
    await $('OK').tap();
    await $.pumpAndSettle();

    await $(TextFormField).at(2).scrollTo().enterText('Sala de Reuniones');

    FocusManager.instance.primaryFocus?.unfocus();
    await $.pumpAndSettle();

    await $(ElevatedButton).scrollTo().tap();
    await $.pumpAndSettle();

    expect($('Event created successfully!'), findsOneWidget);
    await $.pumpAndSettle();

    // 4. Volvemos a la lista de eventos y buscamos el evento recien creado
    await $('Evento Para Eliminar').tap();
    await $.pumpAndSettle();

    // 5. Abrir menu de opciones (solo visible para ROLE_ADMIN o creador)
    await $(Icons.more_vert).tap();
    await $.pumpAndSettle();

    // 6. Seleccionar Delete del popup menu
    await $('Delete').tap();
    await $.pumpAndSettle();

    // 7. Confirmar en el AlertDialog
    expect($('Delete Event'), findsOneWidget);
    await $('Delete').tap();
    await $.pumpAndSettle();

    // 8. Verificar snackbar de exito
    expect($('Event deleted'), findsOneWidget);
  });
}
