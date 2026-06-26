import 'package:app_mobile/core/auth/token_store.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final TokenStore tokenStore;

  /// Invoked after a 401 response clears the stored token, so the app layer
  /// can route back to sign-in. Wired in main.dart to avoid a core -> app
  /// import.
  void Function()? onUnauthorized;

  AuthInterceptor({required this.tokenStore});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenStore.token;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Set standard headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isAuthCall = err.requestOptions.path.startsWith('/auth/');

    // Only end the session when the token is genuinely expired. A 401 from a
    // single endpoint while the token is still valid (a permission quirk or a
    // flaky call) is surfaced in-screen, never logs the user out.
    final sessionExpired =
        err.response?.statusCode == 401 && !isAuthCall && tokenStore.isExpired;

    if (sessionExpired) {
      tokenStore.clear();
      onUnauthorized?.call();
    }

    super.onError(err, handler);
  }
}
