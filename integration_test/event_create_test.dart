import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/mock_test_helpers.dart';

/// US18 - Basic event creation
/// As a manager, I want to create events in the mobile app to organize
/// company meetings and activities.
void main() {
  patrolTest(
    'US18 - Event creation: should navigate to the event creation form',
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

      // Assert - Verify the mock events are shown
      expect($('Sample Event'), findsOneWidget);

      // Act - Tap the FAB to create an event (only visible to ROLE_ADMIN/ROLE_MANAGER)
      await $(Icons.event).tap();
      await $.pumpAndSettle();

      // Assert - Verify the creation form is shown ('Create Event' is both the
      // AppBar title and the submit button, so it matches more than once).
      expect($('Create Event'), findsWidgets);
      expect($('New Event Details'), findsOneWidget);

      // Act - Fill the title and description
      await $(TextFormField).at(0).enterText('Quarterly Planning Meeting');
      await $(TextFormField)
          .at(1)
          .enterText('Event description for patrol tests.');

      // Act - Pick a date (the picker opens on today; confirm with OK)
      await $('No date chosen').tap();
      await $.pumpAndSettle();
      await $('OK').tap();
      await $.pumpAndSettle();

      // Act - Pick a time (confirm the default with OK)
      await $('No time chosen').tap();
      await $.pumpAndSettle();
      await $('OK').tap();
      await $.pumpAndSettle();

      // Act - Open the room dropdown. The hint text "Select a room" exists but
      // isn't hit-testable on its own, so drive the dropdown by its trailing
      // expand icon (unique to the room picker on this form).
      await $(Icons.expand_more).scrollTo().tap();
      await $.pumpAndSettle();

      // Act - Select the mocked room ('Main Hall' from FakeGetSpacesUseCase)
      await $('Main Hall').tap();
      await $.pumpAndSettle();

      // Act - Submit. The submit button is the only ElevatedButton on the form,
      // which disambiguates it from the AppBar's 'Create Event' title.
      await $(ElevatedButton).scrollTo().tap();
      await $.pumpAndSettle();

      // Assert - Verify the success snackbar
      expect($('Event created successfully!'), findsOneWidget);
    },
  );
}
