import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/mock_test_helpers.dart';

/// US35 - Stay signed in
/// As an employee, I want to stay securely signed in so I don't have
/// to re-authenticate frequently.
///
/// US36 - Secure sign-out
/// As an employee, I want to sign out securely so my session ends
/// completely and cannot be reused.
void main() {
  patrolTest(
    'US35/US36 - Session: should sign in, navigate home, sign out and redirect to login',
    ($) async {
      // Arrange
      await dotenv.load(fileName: '.env');
      await initDependencies();
      setupAllMockDependencies();
      await sl<TokenStore>().clear();

      await $.pumpWidgetAndSettle(const MyApp());

      // === US35: Sign in successfully ===

      // Act - Sign in
      await $(TextFormField).at(0).enterText('testadmin');
      await $(TextFormField).at(1).enterText('123456');
      await $('Sign in').tap();
      await $.pumpAndSettle();

      // Assert - Verify we reached home
      expect($('Home'), findsWidgets);

      // === US36: Sign out and redirect to login ===

      // Act - Navigate to Profile
      await $('Profile').tap();
      await $.pumpAndSettle();

      // Act - Open Settings (the icon is settings_outlined)
      await $(Icons.settings_outlined).tap();
      await $.pumpAndSettle();

      // Assert - Verify we are on Settings
      expect($('Settings'), findsOneWidget);
      expect($('Sign Out'), findsOneWidget);

      // Act - Sign out
      await $('Sign Out').tap();
      await $.pumpAndSettle();

      // Assert - Verify the redirect to login
      expect($('Sign in'), findsOneWidget);
      expect($('User Name'), findsOneWidget);
    },
  );
}
