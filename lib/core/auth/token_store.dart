import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the auth JWT: an in-memory copy for synchronous reads (router
/// guard, Dio interceptor) backed by the platform secure storage
/// (Keychain / Keystore) for persistence across launches.
///
/// "Signed in" means *we hold a token that has not expired*. Expiry is read
/// from the JWT's standard `exp` claim locally, so the app only ever signs a
/// user out when their session is genuinely dead — never on a one-off 401
/// from some other endpoint. If the token has no readable `exp`, it is
/// treated as non-expiring and only a server 401 can end the session.
class TokenStore {
  TokenStore({required FlutterSecureStorage storage}) : _storage = storage;

  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;
  String? _token;

  /// Loads the persisted token into memory. Call once before `runApp`.
  Future<void> init() async {
    _token = await _storage.read(key: _key);
  }

  String? get token => _token;

  /// True when a token is present, regardless of whether it has expired.
  bool get hasToken => _token != null;

  /// True when a token is present and its `exp` is in the past. This is the
  /// "session genuinely died" signal the interceptor uses to force sign-out.
  bool get isExpired {
    final token = _token;
    return token != null && _isExpired(token);
  }

  /// True when we hold a token that is still valid. Drives the router guard
  /// and `initialLocation`.
  bool get isSignedIn {
    final token = _token;
    return token != null && !_isExpired(token);
  }

  Future<void> save(String token) async {
    _token = token;
    await _storage.write(key: _key, value: token);
  }

  /// The in-memory copy is cleared synchronously so guards/interceptors see
  /// the signed-out state immediately; secure-storage deletion follows.
  Future<void> clear() {
    _token = null;
    return _storage.delete(key: _key);
  }

  bool _isExpired(String token) {
    final expiry = _expiryOf(token);
    // No readable expiry -> treat as non-expiring; rely on a server 401 to
    // ever end the session rather than locking the user out preemptively.
    if (expiry == null) return false;
    return DateTime.now().toUtc().isAfter(expiry);
  }

  /// Decodes the JWT `exp` claim (seconds since epoch) without any external
  /// dependency. Returns null for non-JWTs or tokens without a numeric `exp`.
  DateTime? _expiryOf(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final claims = json.decode(payload) as Map<String, dynamic>;
      final exp = claims['exp'];
      if (exp is! int) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    } catch (_) {
      return null;
    }
  }
}
