import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/mock_test_helpers.dart';

/// US20 - Event modification
/// As a manager, I want to modify details of existing events
/// to accommodate last-minute changes.
void main() {
  patrolTest(
    'US20 - Event modification: should allow editing an existing event',
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

      // Assert - Verify the mock event is shown
      expect($('Sample Event'), findsOneWidget);

      // Act - Open the event detail
      await $('Sample Event').tap();
      await $.pumpAndSettle();

      // Open the options menu
      await $(Icons.more_vert).tap();
      await $.pumpAndSettle();

      // Seleccionar Edit del PopupMenu
      await $('Edit').tap();
      await $.pumpAndSettle();

      // Assert - Verify the edit screen is shown
      expect($('Edit Event'), findsOneWidget);

      // Assert - The form is pre-filled with the existing event
      expect($('Sample Event'), findsOneWidget);

      // Act - Modify the title and description. Date, time and room are already
      // pre-filled from the existing event, so saving keeps booking 'room-1'.
      await $(TextFormField).at(0).enterText('Updated Event Title');
      await $(TextFormField)
          .at(1)
          .scrollTo()
          .enterText('Updated event description for patrol tests.');

      // Act - Save the changes
      await $('Save Changes').scrollTo().tap();
      await $.pumpAndSettle();

      // Assert - Verify the success snackbar
      expect($('Event updated successfully!'), findsOneWidget);
    },
  );
}
