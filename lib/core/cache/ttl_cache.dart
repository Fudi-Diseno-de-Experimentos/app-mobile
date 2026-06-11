import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A small TTL cache with two layers: an in-memory copy (fast path) and a
/// JSON blob in [SharedPreferences] (survives restarts). Both expire [ttl]
/// after the value was stored.
///
/// One instance manages one value (a list, a map, an entity...) under one
/// persistent [key]; the write timestamp is stored under `'<key>_time'`.
class TtlCache<T> {
  TtlCache({
    required this.prefs,
    required this.key,
    required this.ttl,
    required this.fromJson,
    required this.toJson,
  });

  final SharedPreferences prefs;
  final String key;
  final Duration ttl;
  final T Function(dynamic json) fromJson;
  final dynamic Function(T value) toJson;

  String get _timeKey => '${key}_time';

  T? _value;
  DateTime? _storedAt;

  bool _isFresh(DateTime? storedAt) =>
      storedAt != null && DateTime.now().difference(storedAt) < ttl;

  /// Memory -> persistent -> null.
  T? get() {
    if (_value != null && _isFresh(_storedAt)) return _value;

    try {
      final jsonStr = prefs.getString(key);
      final timeStr = prefs.getString(_timeKey);
      if (jsonStr != null && timeStr != null) {
        final storedAt = DateTime.tryParse(timeStr);
        if (_isFresh(storedAt)) {
          _value = fromJson(jsonDecode(jsonStr));
          _storedAt = storedAt;
          return _value;
        }
      }
    } catch (_) {
      // A corrupt cache entry is treated as a miss.
    }
    return null;
  }

  Future<void> set(T value) async {
    _value = value;
    _storedAt = DateTime.now();
    try {
      await prefs.setString(key, jsonEncode(toJson(value)));
      await prefs.setString(_timeKey, _storedAt!.toIso8601String());
    } catch (_) {
      // Persisting is best-effort; the in-memory copy is already updated.
    }
  }

  Future<void> clear() async {
    _value = null;
    _storedAt = null;
    await prefs.remove(key);
    await prefs.remove(_timeKey);
  }
}
