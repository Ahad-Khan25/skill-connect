import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/errors.dart';
import '../core/validators.dart';
import '../data/cache_store.dart';
import '../data/repository.dart';
import '../models/models.dart';

/// Sign up / sign in / sign out. The session itself is persisted by
/// supabase_flutter, so [status] is restored instantly on app start.
class AuthController extends ChangeNotifier {
  AuthController(this._repo, this._cache);

  final Repository _repo;
  final CacheStore _cache;
  StreamSubscription<bool>? _sub;

  AuthStatus status = AuthStatus.unknown;
  bool busy = false;
  String? error;

  String? get userId => _repo.currentUserId;
  String? get email => _repo.currentEmail;

  /// Name entered at sign-up (prefill for profile setup).
  String? get signUpName => _repo.signUpName;

  /// Call once at startup.
  void init() {
    status = _repo.currentUserId != null ? AuthStatus.signedIn : AuthStatus.signedOut;
    _sub = _repo.authChanges.listen((signedIn) {
      final s = signedIn ? AuthStatus.signedIn : AuthStatus.signedOut;
      if (s != status) {
        status = s;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<String?> signUp(String name, String email, String password) async {
    final v = Validators.name(name) ?? Validators.email(email) ?? Validators.password(password);
    if (v != null) return _fail(v);
    _setBusy(true);
    try {
      final hasSession = await _repo.signUp(name, email, password);
      if (!hasSession) {
        return _fail('Account created! Please confirm your email, then sign in.');
      }
      status = AuthStatus.signedIn;
      error = null;
      return null;
    } catch (e) {
      return _fail(friendlyError(e).message);
    } finally {
      _setBusy(false);
    }
  }

  Future<String?> signIn(String email, String password) async {
    final v = Validators.email(email) ?? (password.isEmpty ? 'Please enter your password' : null);
    if (v != null) return _fail(v);
    _setBusy(true);
    try {
      await _repo.signIn(email, password);
      status = AuthStatus.signedIn;
      error = null;
      return null;
    } catch (e) {
      return _fail(friendlyError(e).message);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() async {
    final uid = userId;
    _setBusy(true);
    await _repo.signOut();
    if (uid != null) await _cache.clearUser(uid);
    status = AuthStatus.signedOut;
    error = null;
    _setBusy(false);
  }

  String _fail(String msg) {
    error = msg;
    notifyListeners();
    return msg;
  }

  void _setBusy(bool b) {
    busy = b;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
