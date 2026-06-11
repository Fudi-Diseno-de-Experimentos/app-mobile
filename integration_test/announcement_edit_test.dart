import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/mock_test_helpers.dart';

/// US12 - Announcement editing
/// As a manager, I want to edit published announcements to fix mistakes
/// or update information.
void main() {
  patrolTest(
    'US12 - Announcement editing: should allow editing an existing announcement',
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

      // Assert - Verify the mock announcements are shown
      expect($('Sample Announcement'), findsOneWidget);

      // Act - Open the announcement detail
      await $('Sample Announcement').tap();
      await $.pumpAndSettle();

      // Open the options menu
      await $(Icons.more_vert).tap();
      await $.pumpAndSettle();

      // Seleccionar Edit del PopupMenu
      await $('Edit').tap();
      await $.pumpAndSettle();

      // Assert - Verify the edit screen is shown
      // 'Edit Announcement' appears in the AppBar and as the page header
      expect($('Edit Announcement'), findsWidgets);
    },
  );
}
