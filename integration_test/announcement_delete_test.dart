import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/mock_test_helpers.dart';

/// US13 - Announcement deletion
/// As a manager, I want to delete obsolete announcements to keep
/// the information up to date.
void main() {
  patrolTest(
    'US13 - Announcement deletion: should delete an announcement and confirm the action',
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
      await $('Files').tap();
      await $.pumpAndSettle();

      // Assert - Verify the announcement exists
      expect($('Sample Announcement'), findsOneWidget);

      // Act - Open the announcement detail
      await $('Sample Announcement').tap();
      await $.pumpAndSettle();

      // Open the options menu
      await $(Icons.more_vert).tap();
      await $.pumpAndSettle();

      // Seleccionar Delete del PopupMenu
      await $('Delete').tap();
      await $.pumpAndSettle();

      // Confirm the deletion in the AlertDialog
      expect($('Delete Announcement'), findsOneWidget);
      await $(AlertDialog).$(TextButton).last.tap();
      await $.pumpAndSettle();

      // Assert - Verify the success snackbar
      expect($('Announcement deleted'), findsOneWidget);
    },
  );
}
