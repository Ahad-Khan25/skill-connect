import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// A user-facing error. Repositories throw this; controllers catch it and
/// return / expose [message]. Never shown as a raw stack trace.
class AppException implements Exception {
  final String message;
  final bool isNetwork;
  const AppException(this.message, {this.isNetwork = false});
  @override
  String toString() => message;
}

const String kNoInternet = 'No internet connection. Please check your network.';

/// Converts any thrown object into a friendly [AppException].
AppException friendlyError(Object e) {
  if (e is AppException) return e;
  if (e is SocketException || e is TimeoutException || e is HandshakeException) {
    return const AppException(kNoInternet, isNetwork: true);
  }
  if (e is AuthException) return AppException(_authMessage(e), isNetwork: _looksOffline(e.message));
  if (e is PostgrestException) {
    // RPCs raise exceptions whose message is already human readable.
    final msg = e.message;
    if (_looksOffline(msg)) return const AppException(kNoInternet, isNetwork: true);
    if (e.code == '42501' || msg.contains('row-level security')) {
      return const AppException('You are not allowed to do that.');
    }
    if (e.code == '23505') return const AppException('That already exists.');
    return AppException(msg.isEmpty ? 'Something went wrong. Please try again.' : msg);
  }
  final text = e.toString();
  if (_looksOffline(text)) return const AppException(kNoInternet, isNetwork: true);
  return const AppException('Something went wrong. Please try again.');
}

bool _looksOffline(String s) {
  final t = s.toLowerCase();
  return t.contains('socketexception') ||
      t.contains('failed host lookup') ||
      t.contains('clientexception') ||
      t.contains('network is unreachable') ||
      t.contains('connection refused') ||
      t.contains('connection closed') ||
      t.contains('connection reset') ||
      t.contains('timed out') ||
      t.contains('xmlhttprequest error') ||
      t.contains('failed to fetch');
}

String _authMessage(AuthException e) {
  final m = e.message.toLowerCase();
  if (_looksOffline(m) || e is AuthRetryableFetchException) return kNoInternet;
  if (m.contains('already registered') || m.contains('already exists') || e.code == 'user_already_exists') {
    return 'This email is already registered. Try signing in.';
  }
  if (m.contains('invalid login') || m.contains('invalid credentials') || e.code == 'invalid_credentials') {
    return 'Incorrect email or password.';
  }
  if (m.contains('email not confirmed')) {
    return 'Please confirm your email first (check your inbox).';
  }
  if (m.contains('password') && m.contains('characters')) {
    return 'Password must be at least 6 characters.';
  }
  if (m.contains('rate limit') || e.statusCode == '429') {
    return 'Too many attempts. Please wait a minute and try again.';
  }
  if (m.contains('invalid') && m.contains('email')) return 'Please enter a valid email address.';
  return e.message;
}
