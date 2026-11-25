import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors.dart';
import '../models/models.dart';
import 'repository.dart';

/// Real backend. Reads go through RLS-protected tables, all writes to
/// requests/teams go through SECURITY DEFINER RPCs (see supabase/schema.sql)
/// so the business rules are enforced atomically on the server.
class SupabaseRepository implements Repository {
  SupabaseClient get _db => Supabase.instance.client;
  static const _timeout = Duration(seconds: 15);

  /// Runs [op] with a timeout and converts any error to [AppException].
  Future<T> _run<T>(Future<T> Function() op) async {
    try {
      return await op().timeout(_timeout);
    } catch (e) {
      throw friendlyError(e);
    }
  }

  // ---------------- auth ----------------
  @override
  String? get currentUserId => _db.auth.currentUser?.id;
  @override
  String? get currentEmail => _db.auth.currentUser?.email;
  @override
  String? get signUpName => _db.auth.currentUser?.userMetadata?['name'] as String?;

  @override
  Stream<bool> get authChanges => _db.auth.onAuthStateChange.map((s) => s.session != null);

  @override
  Future<bool> signUp(String name, String email, String password) => _run(() async {
        final res = await _db.auth.signUp(
          email: email.trim(),
          password: password,
          data: {'name': name.trim()},
        );
        // Supabase returns a user with no identities when the email exists.
        if (res.user != null && (res.user!.identities?.isEmpty ?? false)) {
          throw const AppException('This email is already registered. Try signing in.');
        }
        if (res.session != null) return true;
        // If a database trigger auto-confirmed the user, signing in immediately succeeds.
        try {
          final signInRes = await _db.auth.signInWithPassword(
            email: email.trim(),
            password: password,
          );
          return signInRes.session != null;
        } catch (_) {
          return false;
        }
      });

  @override
  Future<void> signIn(String email, String password) => _run(() async {
        await _db.auth.signInWithPassword(email: email.trim(), password: password);
      });

  @override
  Future<void> signOut() async {
    try {
      await _db.auth.signOut().timeout(_timeout);
    } catch (_) {
      // Offline: at least drop the local session.
      try {
        await _db.auth.signOut(scope: SignOutScope.local);
      } catch (_) {}
    }
  }

  // ---------------- profiles ----------------
  @override
  Future<Profile?> fetchMyProfile() => _run(() async {
        final uid = currentUserId;
        if (uid == null) return null;
        final row = await _db.from('profiles').select().eq('user_id', uid).maybeSingle();
        return row == null ? null : Profile.fromJson(row, myUserId: uid);
      });

  @override
  Future<Profile> saveMyProfile(Profile p) => _run(() async {
        final uid = currentUserId;
        if (uid == null) throw const AppException('Your session has expired. Please sign in again.');
        final row = p.toDbRow()
          ..['user_id'] = uid
          ..['email'] = currentEmail;
        final saved = await _db.from('profiles').upsert(row, onConflict: 'user_id').select().single();
        return Profile.fromJson(saved, myUserId: uid);
      });

  @override
  Future<List<Profile>> fetchProfiles() => _run(() async {
        final uid = currentUserId;
        final rows = await _db.from('profiles').select().order('name');
        return rows.map((r) => Profile.fromJson(r, myUserId: uid)).toList();
      });

  // ---------------- requests ----------------
  @override
  Future<List<TeamRequest>> fetchRequests(String myProfileId) => _run(() async {
        final uid = currentUserId;
        final rows = await _db
            .from('requests')
            .select('id, message, status, created_at, team_id, '
                'from:profiles!requests_from_profile_fkey(*), '
                'to:profiles!requests_to_profile_fkey(*)')
            .neq('status', 'cancelled')
            .or('from_profile.eq.$myProfileId,to_profile.eq.$myProfileId')
            .order('created_at', ascending: false);
        return rows.map((r) {
          final req = TeamRequest.fromJson(r, myProfileId: myProfileId);
          req.from.isMe = req.from.userId == uid;
          req.to.isMe = req.to.userId == uid;
          return req;
        }).toList();
      });

  @override
  Future<void> sendRequest(String toProfileId, String message, {String? teamId}) => _run(() async {
        await _db.rpc('send_request', params: {
          'p_to_profile': toProfileId,
          'p_message': message.trim(),
          'p_team_id': teamId,
        });
      });

  @override
  Future<void> acceptRequest(String id) =>
      _run(() async => await _db.rpc('accept_request', params: {'p_request_id': id}));

  @override
  Future<void> rejectRequest(String id) =>
      _run(() async => await _db.rpc('reject_request', params: {'p_request_id': id}));

  @override
  Future<void> cancelRequest(String id) =>
      _run(() async => await _db.rpc('cancel_request', params: {'p_request_id': id}));

  // ---------------- team ----------------
  @override
  Future<Team?> fetchMyTeam(String myProfileId) => _run(() async {
        final res = await _db.rpc('get_my_team');
        if (res == null) return null;
        final team = Team.fromJson(Map<String, dynamic>.from(res as Map));
        for (final m in team.members) {
          m.profile.isMe = m.profile.id == myProfileId;
        }
        return team;
      });

  @override
  Future<void> createTeam(String title, String projectType, List<String> rolesNeeded) => _run(() async {
        await _db.rpc('create_team', params: {
          'p_title': title.trim(),
          'p_project_type': projectType,
          'p_roles': rolesNeeded,
        });
      });

  @override
  Future<void> leaveTeam(String teamId) =>
      _run(() async => await _db.rpc('leave_team', params: {'p_team_id': teamId}));
}
