import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/mock_test_helpers.dart';

/// US19 - Event cancellation
/// As a manager, I want to cancel events when necessary
/// to avoid confusion.
void main() {
  patrolTest(
    'US19 - Event cancellation: should delete an event and confirm the action',
    ($) async {
      // Arrange - Initial setup with mocks
      await dotenv.load(fileName: '.env');
      await initDependencies();
      setupAllMockDependencies();
      await sl<TokenStore>().clear();

      await $.pumpWidgetAndSettle(const MyApp());

      // Act - Login con datos mock
      await $(TextFormField).at(0).enterText('testadmin');
      await $(TextFormField).at(1).enterText('123456');
      await $('Sign in').tap();
      await $.pumpAndSettle();

      // Navigate to the Feed and switch to the Events tab
      await $('Feed').tap();
      await $.pumpAndSettle();

      await $('Events').tap();
      await $.pumpAndSettle();

      // Assert - Verify the mock event exists
      expect($('Sample Event'), findsOneWidget);

      // Act - Open the event detail
      await $('Sample Event').tap();
      await $.pumpAndSettle();

      // Open the options menu
      await $(Icons.more_vert).tap();
      await $.pumpAndSettle();

      // Seleccionar Delete del PopupMenu
      await $('Delete').tap();
      await $.pumpAndSettle();

      // Confirm the deletion in the AlertDialog
      expect($('Delete Event'), findsOneWidget);
      await $(AlertDialog).$(TextButton).last.tap();
      await $.pumpAndSettle();

      // Assert - Verify the success snackbar
      expect($('Event deleted'), findsOneWidget);
    },
  );
}
