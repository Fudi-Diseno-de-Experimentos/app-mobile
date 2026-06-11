import 'package:app_mobile/app/app.dart';
import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/app/router.dart';
import 'package:app_mobile/core/auth/token_store.dart';
import 'package:app_mobile/core/network/auth_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const _sessionExpiredMessage = 'Your session expired. Please sign in again.';

void _showSessionExpired() {
  rootScaffoldMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text(_sessionExpiredMessage)));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initDependencies();

  // Mid-session expiry: the interceptor detects an expired token on a 401,
  // clears it, then asks us to route back to sign-in and explain why.
  sl<AuthInterceptor>().onUnauthorized = () {
    appRouter.go('/sign-in');
    _showSessionExpired();
  };

  // Cold-start expiry: a token persisted from a previous launch may have
  // expired while the app was closed. Clear it so we land on sign-in, and
  // surface the same message once the first frame is up.
  final tokenStore = sl<TokenStore>();
  if (tokenStore.hasToken && tokenStore.isExpired) {
    await tokenStore.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSessionExpired());
  }

  runApp(const MyApp());
}
