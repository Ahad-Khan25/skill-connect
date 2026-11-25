import 'dart:async';

import '../core/constants.dart';
import '../core/errors.dart';
import '../models/models.dart';
import 'repository.dart';
import 'sample_data.dart';

/// In-memory backend that mirrors the Supabase RPC rules. Used when no
/// Supabase key is configured, so the UI can be built and demoed offline.
///
/// * Sign in with ANY valid email/password -> demo account with a filled profile.
/// * Sign up -> new account WITHOUT a profile (forces profile setup).
class FakeRepository implements Repository {
  FakeRepository() {
    _profiles.addAll(kSampleProfiles.map((p) => p.copyWith()));
  }

  static const _latency = Duration(milliseconds: 450);
  final _auth = StreamController<bool>.broadcast();
  final List<Profile> _profiles = [];
  final List<_Req> _requests = [];
  final List<_Team> _teams = [];
  final Map<String, String> _passwords = {};
  String? _uid;
  String? _email;
  String? _signUpName;
  int _seq = 0;

  String _id() => 'fake-${++_seq}';

  Future<void> _delay() => Future.delayed(_latency);

  @override
  String? get currentUserId => _uid;
  @override
  String? get currentEmail => _email;
  @override
  String? get signUpName => _signUpName;
  @override
  Stream<bool> get authChanges => _auth.stream;

  Profile? get _me => _profiles.where((p) => p.userId != null && p.userId == _uid).firstOrNull;

  Profile _requireMe() {
    final me = _me;
    if (me == null) throw const AppException('Please complete your profile first.');
    return me;
  }

  // ---------------- auth ----------------
  @override
  Future<bool> signUp(String name, String email, String password) async {
    await _delay();
    final e = email.trim().toLowerCase();
    if (_passwords.containsKey(e) || e == 'demo@teamup.app') {
      throw const AppException('This email is already registered. Try signing in.');
    }
    _passwords[e] = password;
    _uid = 'user-$e';
    _email = e;
    _signUpName = name.trim();
    _auth.add(true);
    return true;
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _delay();
    final e = email.trim().toLowerCase();
    if (_passwords.containsKey(e) && _passwords[e] != password) {
      throw const AppException('Incorrect email or password.');
    }
    _uid = 'user-$e';
    _email = e;
    if (!_passwords.containsKey(e) && _me == null) {
      // Unknown email in fake mode -> demo account with a ready profile.
      _passwords[e] = password;
      _signUpName = 'Ahad Khan';
      final me = Profile(
        id: _id(),
        userId: _uid,
        email: e,
        name: 'Ahad Khan',
        department: 'Computer Science',
        semester: 7,
        projectType: 'FYP',
        skills: ['Flutter', 'Dart', 'Firebase'],
        interests: ['Mobile Apps', 'AI', 'Health Tech'],
        skillsNeeded: ['UI/UX Design', 'Figma', 'Technical Writing', 'Machine Learning'],
        availability: ['Evenings', 'Weekends'],
        bio: 'Flutter developer looking for a designer and an ML teammate for my FYP.',
      );
      _profiles.add(me);
      _seedForNewProfile(me);
      // Sample team owned by the demo user.
      _teams.add(_Team(
        id: _id(),
        ownerId: me.id,
        title: 'MediTrack – Health Companion App',
        projectType: 'FYP',
        rolesNeeded: ['Designer', 'Report Writer'],
        members: [
          _Member(me.id, 'Owner'),
          _Member(sampleId(4), 'Data/ML Engineer'),
        ],
      ));
    }
    _auth.add(true);
  }

  @override
  Future<void> signOut() async {
    _uid = null;
    _email = null;
    _auth.add(false);
  }

  // ---------------- profiles ----------------
  @override
  Future<Profile?> fetchMyProfile() async {
    await _delay();
    final me = _me;
    return me?.copyWith(isMe: true);
  }

  @override
  Future<Profile> saveMyProfile(Profile p) async {
    await _delay();
    final existing = _me;
    if (existing != null) {
      final updated = p.copyWith(id: existing.id, userId: _uid, email: _email, isMe: false);
      _profiles[_profiles.indexOf(existing)] = updated;
      return updated.copyWith(isMe: true);
    }
    final created = p.copyWith(id: _id(), userId: _uid, email: _email, isMe: false);
    _profiles.add(created);
    _seedForNewProfile(created); // mirrors the DB trigger
    return created.copyWith(isMe: true);
  }

  void _seedForNewProfile(Profile me) {
    final senders = [sampleId(3), sampleId(15), sampleId(13)];
    for (var i = 0; i < senders.length; i++) {
      _requests.add(_Req(
        id: _id(),
        from: senders[i],
        to: me.id,
        message: kSampleRequestMessages[i],
        status: RequestStatus.pending,
        createdAt: DateTime.now().subtract(Duration(hours: i + 1)),
      ));
    }
  }

  @override
  Future<List<Profile>> fetchProfiles() async {
    await _delay();
    return _profiles.map((p) => p.copyWith(isMe: p.userId != null && p.userId == _uid)).toList();
  }

  Profile _p(String id) => _profiles.firstWhere((p) => p.id == id);

  // ---------------- requests ----------------
  @override
  Future<List<TeamRequest>> fetchRequests(String myProfileId) async {
    await _delay();
    final list = _requests
        .where((r) => r.status != RequestStatus.cancelled && (r.from == myProfileId || r.to == myProfileId))
        .map((r) => TeamRequest(
              id: r.id,
              from: _p(r.from).copyWith(isMe: r.from == myProfileId),
              to: _p(r.to).copyWith(isMe: r.to == myProfileId),
              message: r.message,
              status: r.status,
              createdAt: r.createdAt,
              isSent: r.from == myProfileId,
              teamId: r.teamId,
            ))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> sendRequest(String toProfileId, String message, {String? teamId}) async {
    await _delay();
    final me = _requireMe();
    final msg = message.trim();
    if (toProfileId == me.id) throw const AppException('You cannot send a request to yourself.');
    if (msg.isEmpty) throw const AppException('Please write a short message.');
    if (msg.length > kMaxRequestMessage) throw const AppException('Message is too long (max 200).');
    if (!_profiles.any((p) => p.id == toProfileId)) throw const AppException('Student not found.');
    final dup = _requests.any((r) =>
        r.status == RequestStatus.pending &&
        ((r.from == me.id && r.to == toProfileId) || (r.from == toProfileId && r.to == me.id)));
    if (dup) throw const AppException('There is already a pending request with this student.');
    _requests.add(_Req(
      id: _id(),
      from: me.id,
      to: toProfileId,
      message: msg,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      teamId: teamId,
    ));
  }

  _Req _pending(String id) {
    final r = _requests.where((r) => r.id == id).firstOrNull;
    if (r == null) throw const AppException('Request not found.');
    if (r.status != RequestStatus.pending) {
      throw AppException('This request is already ${r.status.name}.');
    }
    return r;
  }

  @override
  Future<void> acceptRequest(String id) async {
    await _delay();
    final me = _requireMe();
    final r = _pending(id);
    if (r.to != me.id) throw const AppException('Only the receiver can accept this request.');

    _Team? team;
    String joinerId = r.from;
    if (r.teamId != null) {
      team = _teams.where((t) => t.id == r.teamId).firstOrNull;
      // Invitation: the sender is already in that team, so I (receiver) join.
      if (team != null && team.members.any((m) => m.profileId == r.from)) joinerId = me.id;
    }
    team ??= _myTeam(me.id);
    if (team == null) {
      team = _Team(
        id: _id(),
        ownerId: me.id,
        title: "${me.name}'s Team",
        projectType: me.projectType,
        rolesNeeded: ['Developer', 'Designer', 'Tester', 'Report Writer'],
        members: [_Member(me.id, 'Owner')],
      );
      _teams.add(team);
    }
    if (team.members.any((m) => m.profileId == joinerId)) {
      throw const AppException('This student is already a member of the team.');
    }
    final role = bestRoleFor(_p(joinerId).skills, team.rolesNeeded);
    team.members.add(_Member(joinerId, role));
    team.rolesNeeded.remove(role);
    r.status = RequestStatus.accepted;
  }

  @override
  Future<void> rejectRequest(String id) async {
    await _delay();
    final me = _requireMe();
    final r = _pending(id);
    if (r.to != me.id) throw const AppException('Only the receiver can reject this request.');
    r.status = RequestStatus.rejected;
  }

  @override
  Future<void> cancelRequest(String id) async {
    await _delay();
    final me = _requireMe();
    final r = _pending(id);
    if (r.from != me.id) throw const AppException('Only the sender can cancel this request.');
    r.status = RequestStatus.cancelled;
  }

  // ---------------- team ----------------
  _Team? _myTeam(String profileId) =>
      _teams.where((t) => t.ownerId == profileId).firstOrNull ??
      _teams.reversed.where((t) => t.members.any((m) => m.profileId == profileId)).firstOrNull;

  @override
  Future<Team?> fetchMyTeam(String myProfileId) async {
    await _delay();
    final t = _myTeam(myProfileId);
    if (t == null) return null;
    return Team(
      id: t.id,
      title: t.title,
      projectType: t.projectType,
      openRoles: List.of(t.rolesNeeded),
      iAmOwner: t.ownerId == myProfileId,
      members: t.members
          .map((m) => TeamMember(
                profile: _p(m.profileId).copyWith(isMe: m.profileId == myProfileId),
                role: m.role,
                isOwner: m.profileId == t.ownerId,
              ))
          .toList(),
    );
  }

  @override
  Future<void> createTeam(String title, String projectType, List<String> rolesNeeded) async {
    await _delay();
    final me = _requireMe();
    if (_myTeam(me.id) != null) throw const AppException('You are already in a team. Leave it first.');
    _teams.add(_Team(
      id: _id(),
      ownerId: me.id,
      title: title.trim(),
      projectType: projectType,
      rolesNeeded: List.of(rolesNeeded),
      members: [_Member(me.id, 'Owner')],
    ));
  }

  @override
  Future<void> leaveTeam(String teamId) async {
    await _delay();
    final me = _requireMe();
    final t = _teams.where((t) => t.id == teamId).firstOrNull;
    if (t == null) throw const AppException('Team not found.');
    final m = t.members.where((m) => m.profileId == me.id).firstOrNull;
    if (m == null) throw const AppException('You are not a member of this team.');
    if (t.ownerId == me.id) {
      _teams.remove(t); // owner leaving disbands the team
    } else {
      t.members.remove(m);
      if (kRoles.contains(m.role)) t.rolesNeeded.add(m.role);
    }
  }
}

/// Best open role for a set of skills (max role-skill overlap), else the
/// first open role, else 'Member'. Same rule as SQL `best_role()`.
String bestRoleFor(List<String> skills, List<String> openRoles) {
  if (openRoles.isEmpty) return 'Member';
  String best = openRoles.first;
  int bestScore = 0;
  for (final r in openRoles) {
    final s = (kRoleSkills[r] ?? const []).where(skills.contains).length;
    if (s > bestScore) {
      best = r;
      bestScore = s;
    }
  }
  return best;
}

class _Req {
  _Req({
    required this.id,
    required this.from,
    required this.to,
    required this.message,
    required this.status,
    required this.createdAt,
    this.teamId,
  });
  final String id, from, to, message;
  RequestStatus status;
  final DateTime createdAt;
  final String? teamId;
}

class _Member {
  _Member(this.profileId, this.role);
  final String profileId;
  final String role;
}

class _Team {
  _Team({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.projectType,
    required this.rolesNeeded,
    required this.members,
  });
  final String id, ownerId, title, projectType;
  final List<String> rolesNeeded;
  final List<_Member> members;
}
