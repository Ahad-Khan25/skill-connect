import 'dart:async';

import '../core/constants.dart';
import '../core/errors.dart';
import '../models/models.dart';
import 'repository.dart';
import 'sample_data.dart';

/// In-memory backend that mirrors the Supabase RPC rules. Used when no
/// Supabase key is configured or FAKE_BACKEND=true.
///
/// * Sign in with ANY valid email/password -> demo account with a filled profile,
///   two sample projects (so you can switch projects and see matches change),
///   and 5 open teams posted by other students to browse & apply to.
/// * Sign up -> new account WITHOUT a profile (forces profile setup).
class FakeRepository implements Repository {
  FakeRepository() {
    _profiles.addAll(kSampleProfiles.map((p) => p.copyWith()));
    for (final t in buildSampleOpenTeams()) {
      final ownerId = t.owner?.profile.id ?? t.members.first.profile.id;
      _teams.add(_Team(
        id: t.id,
        ownerId: ownerId,
        title: t.title,
        description: t.description,
        projectType: t.projectType,
        rolesNeeded: List.of(t.openRoles),
        requiredSkills: List.of(t.requiredSkills),
        domainTags: List.of(t.domainTags),
        members: t.members.map((m) => _Member(m.profile.id, m.role)).toList(),
      ));
    }
  }

  static const _latency = Duration(milliseconds: 350);
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
      // Unknown email in fake mode -> demo account with a ready personal profile,
      // and NO pre-existing dummy projects (projects are created fresh by the user!).
      _passwords[e] = password;
      _signUpName = 'Ahad Khan';
      final me = Profile(
        id: _id(),
        userId: _uid,
        email: e,
        name: 'Ahad Khan',
        university: 'COMSATS Wah',
        department: 'Computer Science',
        semester: 7,
        projectType: 'FYP',
        skills: ['Flutter', 'Dart', 'Firebase', 'Git'],
        interests: ['Mobile Apps', 'AI', 'Health Tech'],
        skillsNeeded: ['UI/UX Design', 'Figma'],
        availability: ['Evenings', 'Weekends'],
        workExperience: 'Flutter Mobile App Intern at Systems Ltd (Summer 2025); GDSC Mobile Lead.',
        bio: 'Full-stack Flutter developer building AI & healthcare mobile solutions.',
      );
      _profiles.add(me);
      _seedForNewProfile(me);
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
    final senders = [sampleId(3), sampleId(4), sampleId(5)];
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
        .map((r) {
          final t = r.teamId != null ? _teams.where((x) => x.id == r.teamId).firstOrNull : null;
          return TeamRequest(
            id: r.id,
            from: _p(r.from).copyWith(isMe: r.from == myProfileId),
            to: _p(r.to).copyWith(isMe: r.to == myProfileId),
            message: r.message,
            status: r.status,
            createdAt: r.createdAt,
            isSent: r.from == myProfileId,
            teamId: r.teamId,
            teamTitle: t?.title,
          );
        })
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
    team ??= _myPrimaryTeam(me.id);
    if (team == null) {
      team = _Team(
        id: _id(),
        ownerId: me.id,
        title: "${me.name}'s Project Team",
        description: 'Project team created by ${me.name}.',
        projectType: me.projectType,
        rolesNeeded: ['Developer', 'Designer', 'Tester', 'Report Writer'],
        requiredSkills: List.of(me.skillsNeeded),
        domainTags: List.of(me.interests),
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

  // ---------------- teams & projects ----------------
  _Team? _myPrimaryTeam(String profileId) =>
      _teams.where((t) => t.ownerId == profileId).firstOrNull ??
      _teams.reversed.where((t) => t.members.any((m) => m.profileId == profileId)).firstOrNull;

  Team _toTeamModel(_Team t, String myProfileId) => Team(
        id: t.id,
        title: t.title,
        description: t.description,
        projectType: t.projectType,
        openRoles: List.of(t.rolesNeeded),
        requiredSkills: List.of(t.requiredSkills),
        domainTags: List.of(t.domainTags),
        iAmOwner: t.ownerId == myProfileId,
        members: t.members
            .map((m) => TeamMember(
                  profile: _p(m.profileId).copyWith(isMe: m.profileId == myProfileId),
                  role: m.role,
                  isOwner: m.profileId == t.ownerId,
                ))
            .toList(),
      );

  @override
  Future<Team?> fetchMyTeam(String myProfileId) async {
    await _delay();
    final t = _myPrimaryTeam(myProfileId);
    return t == null ? null : _toTeamModel(t, myProfileId);
  }

  @override
  Future<List<Team>> fetchMyTeams(String myProfileId) async {
    await _delay();
    return _teams
        .where((t) => t.ownerId == myProfileId || t.members.any((m) => m.profileId == myProfileId))
        .map((t) => _toTeamModel(t, myProfileId))
        .toList();
  }

  @override
  Future<List<Team>> fetchOpenTeams(String myProfileId) async {
    await _delay();
    return _teams
        .where((t) =>
            t.ownerId != myProfileId &&
            !t.members.any((m) => m.profileId == myProfileId) &&
            (t.rolesNeeded.isNotEmpty || t.requiredSkills.isNotEmpty))
        .map((t) => _toTeamModel(t, myProfileId))
        .toList();
  }

  @override
  Future<Team> createTeam(
    String title,
    String projectType,
    List<String> rolesNeeded, {
    String description = '',
    List<String> requiredSkills = const [],
    List<String> domainTags = const [],
  }) async {
    await _delay();
    final me = _requireMe();
    final impliedSkills = <String>{
      ...requiredSkills,
      for (final r in rolesNeeded) ...(kRoleSkills[r] ?? const []),
    }.toList();
    final created = _Team(
      id: _id(),
      ownerId: me.id,
      title: title.trim(),
      description: description.trim(),
      projectType: projectType,
      rolesNeeded: List.of(rolesNeeded),
      requiredSkills: impliedSkills,
      domainTags: domainTags.isNotEmpty ? List.of(domainTags) : List.of(me.interests),
      members: [_Member(me.id, 'Owner')],
    );
    _teams.insert(0, created);
    return _toTeamModel(created, me.id);
  }

  @override
  Future<Team> updateTeam(
    String teamId, {
    required String title,
    required String description,
    required String projectType,
    required List<String> rolesNeeded,
    required List<String> requiredSkills,
    required List<String> domainTags,
  }) async {
    await _delay();
    final me = _requireMe();
    final idx = _teams.indexWhere((t) => t.id == teamId);
    if (idx < 0) throw const AppException('Project not found.');
    final old = _teams[idx];
    if (old.ownerId != me.id) throw const AppException('Only the project owner can edit project details.');
    final updated = _Team(
      id: old.id,
      ownerId: old.ownerId,
      title: title.trim(),
      description: description.trim(),
      projectType: projectType,
      rolesNeeded: List.of(rolesNeeded),
      requiredSkills: List.of(requiredSkills),
      domainTags: List.of(domainTags),
      members: List.of(old.members),
    );
    _teams[idx] = updated;
    return _toTeamModel(updated, me.id);
  }

  @override
  Future<void> removeTeamMember(String teamId, String memberProfileId) async {
    await _delay();
    final me = _requireMe();
    final t = _teams.where((t) => t.id == teamId).firstOrNull;
    if (t == null) throw const AppException('Project not found.');
    if (t.ownerId != me.id) throw const AppException('Only the project owner can remove members.');
    if (memberProfileId == me.id) throw const AppException('Use Disband Project to remove yourself as owner.');
    final m = t.members.where((x) => x.profileId == memberProfileId).firstOrNull;
    if (m == null) throw const AppException('Member not found in this project.');
    t.members.remove(m);
    if (kRoles.contains(m.role) && !t.rolesNeeded.contains(m.role)) {
      t.rolesNeeded.add(m.role);
    }
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
      if (kRoles.contains(m.role) && !t.rolesNeeded.contains(m.role)) {
        t.rolesNeeded.add(m.role);
      }
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
    this.description = '',
    required this.projectType,
    required this.rolesNeeded,
    this.requiredSkills = const [],
    this.domainTags = const [],
    required this.members,
  });
  final String id, ownerId, title, description, projectType;
  final List<String> rolesNeeded;
  final List<String> requiredSkills;
  final List<String> domainTags;
  final List<_Member> members;
}
