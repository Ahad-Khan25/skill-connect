/// Pure input validators. Return an error message, or null when valid.
library;

import 'constants.dart';

final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class Validators {
  static String? name(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Please enter your name';
    if (s.length < 2) return 'Name is too short';
    if (s.length > 50) return 'Name is too long (max 50)';
    return null;
  }

  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Please enter your email';
    if (!_emailRe.hasMatch(s)) return 'Please enter a valid email address';
    return null;
  }

  static String? password(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Please enter a password';
    if (s.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? requestMessage(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Please write a short message';
    if (s.length > kMaxRequestMessage) return 'Message is too long (max $kMaxRequestMessage)';
    return null;
  }

  static String? teamTitle(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Please enter a team / project title';
    if (s.length > kMaxTeamTitle) return 'Title is too long (max $kMaxTeamTitle)';
    return null;
  }

  static String? bio(String? v) {
    final s = (v ?? '').trim();
    if (s.length > kMaxBioLength) return 'Bio is too long (max $kMaxBioLength)';
    return null;
  }
}
