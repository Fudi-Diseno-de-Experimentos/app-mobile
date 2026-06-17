import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/mock_test_helpers.dart';

/// US10 - Basic announcement publishing
/// As a manager, I want to publish announcements in the mobile app so
/// employees stay informed about company news.
void main() {
  patrolTest(
    'US10 - Announcement publishing: should create an announcement successfully',
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

      // Navigate to the announcements feed (Announcements is selected by default)
      await $('Feed').tap();
      await $.pumpAndSettle();

      // Tap the FAB to create an announcement
      await $(Icons.add).tap();
      await $.pumpAndSettle();

      // Assert - Verify we are on the creation page
      expect($('Create Announcement'), findsOneWidget);
      expect($('New Announcement'), findsOneWidget);

      // Act - Fill the title
      await $(TextFormField).at(0).enterText('New Sample Announcement');

      // Act - Change the priority from NORMAL to URGENT
      await $(DropdownButtonFormField<String>).tap();
      await $.pumpAndSettle();
      await $('URGENT').tap();
      await $.pumpAndSettle();

      // Assert - The selected priority is reflected in the field
      expect($(DropdownButtonFormField<String>).$('URGENT'), findsOneWidget);

      // Act - Fill the description
      await $(TextFormField).at(1).scrollTo().enterText('Announcement description for patrol tests.');

      // Tap Publish Announcement
      await $('Publish Announcement').scrollTo().tap();
      await $.pumpAndSettle();

      // Assert - Verify the success snackbar
      expect($('Announcement published successfully!'), findsOneWidget);
    },
  );
}
