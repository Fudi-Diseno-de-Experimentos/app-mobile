import 'dart:convert';

import 'package:app_mobile/core/auth/token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in for the platform secure storage. Routes the three
/// methods TokenStore uses through noSuchMethod so we don't have to mirror
/// FlutterSecureStorage's long named-parameter signatures.
class _MapSecureStorage implements FlutterSecureStorage {
  final Map<String, String> store = {};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final key = invocation.namedArguments[#key] as String?;
    switch (invocation.memberName) {
      case #read:
        return Future<String?>.value(store[key]);
      case #write:
        final value = invocation.namedArguments[#value] as String?;
        if (value == null) {
          store.remove(key);
        } else {
          store[key!] = value;
        }
        return Future<void>.value();
      case #delete:
        store.remove(key);
        return Future<void>.value();
      default:
        return super.noSuchMethod(invocation);
    }
  }
}

/// Builds a structurally valid JWT (`header.payload.signature`) whose payload
/// carries the given `exp` claim, in seconds since epoch.
String _jwtExpiringAt(DateTime expiry) {
  String segment(Map<String, dynamic> data) =>
      base64Url.encode(utf8.encode(json.encode(data)));
  final header = segment({'alg': 'HS256', 'typ': 'JWT'});
  final payload =
      segment({'exp': expiry.toUtc().millisecondsSinceEpoch ~/ 1000});
  return '$header.$payload.signature';
}

void main() {
  late TokenStore tokenStore;

  setUp(() {
    tokenStore = TokenStore(storage: _MapSecureStorage());
  });

  group('TokenStore expiry', () {
    test('an unexpired JWT counts as signed in', () async {
      await tokenStore
          .save(_jwtExpiringAt(DateTime.now().add(const Duration(hours: 1))));

      expect(tokenStore.hasToken, isTrue);
      expect(tokenStore.isExpired, isFalse);
      expect(tokenStore.isSignedIn, isTrue);
    });

    test('an expired JWT is held but not signed in', () async {
      await tokenStore.save(
        _jwtExpiringAt(DateTime.now().subtract(const Duration(minutes: 1))),
      );

      expect(tokenStore.hasToken, isTrue);
      expect(tokenStore.isExpired, isTrue);
      expect(tokenStore.isSignedIn, isFalse);
    });

    test('a token without a readable exp never expires locally', () async {
      await tokenStore.save('opaque-non-jwt-token');

      expect(tokenStore.hasToken, isTrue);
      expect(tokenStore.isExpired, isFalse);
      expect(tokenStore.isSignedIn, isTrue);
    });

    test('no token means signed out', () {
      expect(tokenStore.hasToken, isFalse);
      expect(tokenStore.isExpired, isFalse);
      expect(tokenStore.isSignedIn, isFalse);
    });

    test('clear() removes the token', () async {
      await tokenStore
          .save(_jwtExpiringAt(DateTime.now().add(const Duration(hours: 1))));
      await tokenStore.clear();

      expect(tokenStore.hasToken, isFalse);
      expect(tokenStore.isSignedIn, isFalse);
    });

    test('init() restores a persisted token across instances', () async {
      final storage = _MapSecureStorage();
      final valid =
          _jwtExpiringAt(DateTime.now().add(const Duration(hours: 1)));
      await TokenStore(storage: storage).save(valid);

      final restored = TokenStore(storage: storage);
      await restored.init();

      expect(restored.token, valid);
      expect(restored.isSignedIn, isTrue);
    });
  });
}
