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
      await $('Files').tap();
      await $.pumpAndSettle();

      await $('Events').tap();
      await $.pumpAndSettle();

      // Assert - Verify the mock events are shown
      expect($('Sample Event'), findsOneWidget);

      // Act - Tap the FAB to create an event (only visible to ROLE_ADMIN/ROLE_MANAGER)
      await $(Icons.event).tap();
      await $.pumpAndSettle();

      // Assert - Verify the creation form is shown
      expect($('Create Event'), findsOneWidget);
      expect($('New Event Details'), findsOneWidget);
    },
  );
}
