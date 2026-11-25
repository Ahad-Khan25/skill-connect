import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Tiny JSON cache on top of shared_preferences.
/// Keys are namespaced per signed-in user so accounts never see each
/// other's cached data; [clearUser] wipes them on sign-out.
class CacheStore {
  CacheStore._(this._prefs);
  final SharedPreferences _prefs;

  static Future<CacheStore> create() async => CacheStore._(await SharedPreferences.getInstance());

  static const _prefix = 'teamup_cache';

  String _key(String userId, String name) => '$_prefix:$userId:$name';

  Future<void> write(String userId, String name, Object? json) async {
    try {
      await _prefs.setString(_key(userId, name), jsonEncode(json));
    } catch (_) {
      // Cache failures must never break the app.
    }
  }

  /// Returns the decoded JSON, or null if missing/corrupt.
  dynamic read(String userId, String name) {
    try {
      final raw = _prefs.getString(_key(userId, name));
      if (raw == null) return null;
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  bool has(String userId, String name) => _prefs.containsKey(_key(userId, name));

  Future<void> clearUser(String userId) async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('$_prefix:$userId:')).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}

/// Cache entry names.
class CacheKeys {
  static const me = 'me';
  static const profiles = 'profiles';
  static const requests = 'requests';
  static const team = 'team';
}
