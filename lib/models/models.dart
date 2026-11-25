/// Data models shared by the data layer, controllers and UI.
library;

enum LoadState { loading, ready, empty, error }

enum RequestStatus { pending, accepted, rejected, cancelled }

RequestStatus requestStatusFrom(String? s) => RequestStatus.values
    .firstWhere((e) => e.name == s, orElse: () => RequestStatus.pending);

List<String> _strList(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toList() : <String>[];

class Profile {
  String id;
  String? userId;
  String name;
  String department;
  String projectType;
  String bio;
  int semester;
  List<String> skills;
  List<String> interests;
  List<String> skillsNeeded;
  List<String> availability;
  String? avatarUrl;
  bool isMe;
  String? email;

  Profile({
    this.id = '',
    this.userId,
    required this.name,
    required this.department,
    required this.semester,
    this.projectType = 'FYP',
    this.bio = '',
    List<String>? skills,
    List<String>? interests,
    List<String>? skillsNeeded,
    List<String>? availability,
    this.avatarUrl,
    this.isMe = false,
    this.email,
  })  : skills = skills ?? [],
        interests = interests ?? [],
        skillsNeeded = skillsNeeded ?? [],
        availability = availability ?? [];

  /// Initials for avatar placeholders, e.g. "Ahad Khan" -> "AK".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Profile copyWith({
    String? id,
    String? userId,
    String? name,
    String? department,
    String? projectType,
    String? bio,
    int? semester,
    List<String>? skills,
    List<String>? interests,
    List<String>? skillsNeeded,
    List<String>? availability,
    String? avatarUrl,
    bool? isMe,
    String? email,
  }) =>
      Profile(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        department: department ?? this.department,
        projectType: projectType ?? this.projectType,
        bio: bio ?? this.bio,
        semester: semester ?? this.semester,
        skills: List.of(skills ?? this.skills),
        interests: List.of(interests ?? this.interests),
        skillsNeeded: List.of(skillsNeeded ?? this.skillsNeeded),
        availability: List.of(availability ?? this.availability),
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isMe: isMe ?? this.isMe,
        email: email ?? this.email,
      );

  /// Accepts a Supabase `profiles` row (snake_case) or a cached map.
  factory Profile.fromJson(Map<String, dynamic> j, {String? myUserId}) {
    final uid = j['user_id'] as String?;
    return Profile(
      id: (j['id'] ?? '').toString(),
      userId: uid,
      name: (j['name'] ?? '').toString(),
      department: (j['department'] ?? '').toString(),
      semester: (j['semester'] as num?)?.toInt() ?? 0,
      projectType: (j['project_type'] ?? 'FYP').toString(),
      bio: (j['bio'] ?? '').toString(),
      skills: _strList(j['skills']),
      interests: _strList(j['interests']),
      skillsNeeded: _strList(j['skills_needed']),
      availability: _strList(j['availability']),
      avatarUrl: j['avatar_url'] as String?,
      email: j['email'] as String?,
      isMe: myUserId != null ? (uid != null && uid == myUserId) : (j['is_me'] == true),
    );
  }

  /// Full map (used for the local cache).
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'department': department,
        'semester': semester,
        'project_type': projectType,
        'bio': bio,
        'skills': skills,
        'interests': interests,
        'skills_needed': skillsNeeded,
        'availability': availability,
        'avatar_url': avatarUrl,
        'email': email,
        'is_me': isMe,
      };

  /// Columns written to Supabase on save.
  Map<String, dynamic> toDbRow() => {
        'name': name.trim(),
        'department': department,
        'semester': semester,
        'project_type': projectType,
        'bio': bio.trim(),
        'skills': skills,
        'interests': interests,
        'skills_needed': skillsNeeded,
        'availability': availability,
        'avatar_url': avatarUrl,
      };
}

class TeamRequest {
  String id;
  Profile from;
  Profile to;
  String message;
  RequestStatus status;
  DateTime createdAt;

  /// True when I am the sender.
  bool isSent;
  String? teamId;

  TeamRequest({
    required this.id,
    required this.from,
    required this.to,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.isSent,
    this.teamId,
  });

  /// The other person (receiver for sent requests, sender for received).
  Profile get other => isSent ? to : from;

  factory TeamRequest.fromJson(Map<String, dynamic> j, {String? myProfileId}) {
    final from = Profile.fromJson(Map<String, dynamic>.from(j['from'] as Map));
    final to = Profile.fromJson(Map<String, dynamic>.from(j['to'] as Map));
    return TeamRequest(
      id: j['id'].toString(),
      from: from,
      to: to,
      message: (j['message'] ?? '').toString(),
      status: requestStatusFrom(j['status'] as String?),
      createdAt: DateTime.tryParse((j['created_at'] ?? '').toString())?.toLocal() ?? DateTime.now(),
      isSent: myProfileId != null ? from.id == myProfileId : j['is_sent'] == true,
      teamId: j['team_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from.toJson(),
        'to': to.toJson(),
        'message': message,
        'status': status.name,
        'created_at': createdAt.toUtc().toIso8601String(),
        'is_sent': isSent,
        'team_id': teamId,
      };
}

class TeamMember {
  Profile profile;
  String role;
  bool isOwner;

  TeamMember({required this.profile, required this.role, this.isOwner = false});

  factory TeamMember.fromJson(Map<String, dynamic> j) => TeamMember(
        profile: Profile.fromJson(Map<String, dynamic>.from(j['profile'] as Map)),
        role: (j['role'] ?? 'Member').toString(),
        isOwner: j['is_owner'] == true,
      );

  Map<String, dynamic> toJson() => {
        'profile': profile.toJson(),
        'role': role,
        'is_owner': isOwner,
      };
}

class Team {
  String id;
  String title;
  String projectType;
  List<String> openRoles;
  List<TeamMember> members;
  bool iAmOwner;

  Team({
    required this.id,
    required this.title,
    required this.projectType,
    required this.openRoles,
    required this.members,
    required this.iAmOwner,
  });

  TeamMember? get owner => members.where((m) => m.isOwner).firstOrNull;

  factory Team.fromJson(Map<String, dynamic> j) => Team(
        id: j['id'].toString(),
        title: (j['title'] ?? '').toString(),
        projectType: (j['project_type'] ?? '').toString(),
        openRoles: _strList(j['open_roles']),
        members: (j['members'] as List? ?? [])
            .map((m) => TeamMember.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList(),
        iAmOwner: j['i_am_owner'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'project_type': projectType,
        'open_roles': openRoles,
        'members': members.map((m) => m.toJson()).toList(),
        'i_am_owner': iAmOwner,
      };
}

class MatchResult {
  Profile profile;

  /// 0-100.
  int score;

  /// Human readable reasons, most important first.
  List<String> reasons;

  /// Skills of the candidate that I need.
  List<String> matchedSkills;

  MatchResult({
    required this.profile,
    required this.score,
    required this.reasons,
    required this.matchedSkills,
  });
}

/// Filters for the Discover screen. Null = "any".
class DiscoverFilters {
  final String? department;
  final int? semester;
  final String? skill;
  final String? projectType;

  const DiscoverFilters({this.department, this.semester, this.skill, this.projectType});

  bool get isActive => department != null || semester != null || skill != null || projectType != null;

  int get activeCount =>
      [department, semester, skill, projectType].where((e) => e != null).length;

  /// Use [clearX] flags to set a field back to null.
  DiscoverFilters copyWith({
    String? department,
    int? semester,
    String? skill,
    String? projectType,
    bool clearDepartment = false,
    bool clearSemester = false,
    bool clearSkill = false,
    bool clearProjectType = false,
  }) =>
      DiscoverFilters(
        department: clearDepartment ? null : (department ?? this.department),
        semester: clearSemester ? null : (semester ?? this.semester),
        skill: clearSkill ? null : (skill ?? this.skill),
        projectType: clearProjectType ? null : (projectType ?? this.projectType),
      );
}

enum SortOption { bestMatch, name, semester }

enum AuthStatus { unknown, signedOut, signedIn }
