import '../core/constants.dart';
import '../core/errors.dart';
import '../core/validators.dart';
import '../data/cache_store.dart';
import '../data/repository.dart';
import '../models/models.dart';
import 'base_controller.dart';
import 'profile_controller.dart';

/// Manages:
/// * [myTeams]   – all projects/teams I own or belong to (multiple projects supported!)
/// * [team]      – currently active project/team (switching this updates Smart Match!)
/// * [openTeams] – public open teams posted by other students that I can apply to join.
class TeamController extends BaseController {
  TeamController(this._repo, this._cache, this._profile);

  final Repository _repo;
  final CacheStore _cache;
  final ProfileController _profile;
  String? _uid;

  Team? team;
  List<Team> myTeams = [];
  List<Team> openTeams = [];
  bool busy = false;

  /// Switch the active project used by Smart Match & Discover.
  void selectActiveTeam(String? teamId) {
    if (teamId == null) {
      team = myTeams.firstOrNull;
    } else {
      team = myTeams.where((t) => t.id == teamId).firstOrNull ?? team;
    }
    emit();
  }

  /// Load cached team(s) instantly; network refresh happens once my profile is known.
  void start(String uid) {
    _uid = uid;
    final cachedMy = _cache.read(uid, CacheKeys.myTeams);
    if (cachedMy is List) {
      myTeams = cachedMy.map((e) => Team.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      team = myTeams.firstOrNull;
      state = myTeams.isEmpty ? LoadState.empty : LoadState.ready;
    } else if (_cache.has(uid, CacheKeys.team)) {
      final cached = _cache.read(uid, CacheKeys.team);
      team = cached is Map ? Team.fromJson(Map<String, dynamic>.from(cached)) : null;
      myTeams = team == null ? [] : [team!];
      state = team == null ? LoadState.empty : LoadState.ready;
    } else {
      team = null;
      myTeams = [];
      state = LoadState.loading;
    }

    final cachedOpen = _cache.read(uid, CacheKeys.openTeams);
    if (cachedOpen is List) {
      openTeams = cachedOpen.map((e) => Team.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } else {
      openTeams = [];
    }
    emit();
  }

  @override
  Future<void> refresh() async {
    final uid = _uid;
    if (uid == null) return;
    final myId = _profile.me?.id;
    if (myId == null) {
      if (_profile.state == LoadState.error && team == null) {
        state = LoadState.error;
        error = _profile.error;
      } else if (_profile.state == LoadState.empty) {
        team = null;
        myTeams = [];
        state = LoadState.empty;
      }
      emit();
      return;
    }
    if (myTeams.isEmpty && state != LoadState.empty) {
      state = LoadState.loading;
      emit();
    }
    try {
      final results = await Future.wait([
        _repo.fetchMyTeams(myId),
        _repo.fetchOpenTeams(myId),
      ]);
      if (uid != _uid) return;
      final prevActiveId = team?.id;
      myTeams = results[0];
      openTeams = results[1];
      team = (prevActiveId != null
              ? myTeams.where((t) => t.id == prevActiveId).firstOrNull
              : null) ??
          myTeams.firstOrNull;
      offline = false;
      error = null;
      state = myTeams.isEmpty && openTeams.isEmpty ? LoadState.empty : LoadState.ready;
      await _cache.write(uid, CacheKeys.team, team?.toJson());
      await _cache.write(uid, CacheKeys.myTeams, myTeams.map((t) => t.toJson()).toList());
      await _cache.write(uid, CacheKeys.openTeams, openTeams.map((t) => t.toJson()).toList());
    } catch (e) {
      final err = friendlyError(e);
      error = err.message;
      if (_cache.has(uid, CacheKeys.team) || _cache.has(uid, CacheKeys.myTeams)) {
        offline = err.isNetwork;
        state = myTeams.isEmpty && openTeams.isEmpty ? LoadState.empty : LoadState.ready;
      } else {
        state = LoadState.error;
      }
    }
    emit();
  }

  /// Create a new project/team (multiple projects are allowed; newly created
  /// project becomes the active project for Smart Match).
  Future<String?> create(
    String title,
    String projectType,
    List<String> rolesNeeded, {
    String description = '',
    List<String> requiredSkills = const [],
    List<String> domainTags = const [],
  }) async {
    final v = Validators.teamTitle(title) ??
        (kProjectTypes.contains(projectType) ? null : 'Please select a project type') ??
        (rolesNeeded.isEmpty && requiredSkills.isEmpty
            ? 'Pick at least one role or skill you need'
            : null);
    if (v != null) return v;
    if (_profile.me == null) return 'Please complete your profile first.';
    busy = true;
    emit();
    try {
      final created = await _repo.createTeam(
        title.trim(),
        projectType,
        rolesNeeded.toSet().toList(),
        description: description.trim(),
        requiredSkills: requiredSkills.toSet().toList(),
        domainTags: domainTags.toSet().toList(),
      );
      await refresh();
      selectActiveTeam(created.id);
      return null;
    } catch (e) {
      return friendlyError(e).message;
    } finally {
      busy = false;
      emit();
    }
  }

  /// Leave the active team (or the team specified by [teamId]).
  /// If I am the owner, that project/team is disbanded.
  Future<String?> leave([String? teamId]) async {
    final targetId = teamId ?? team?.id;
    if (targetId == null) return 'You are not in a team.';
    return _mutate(() => _repo.leaveTeam(targetId));
  }

  Future<String?> _mutate(Future<void> Function() op) async {
    busy = true;
    emit();
    try {
      await op();
      await refresh();
      return null;
    } catch (e) {
      return friendlyError(e).message;
    } finally {
      busy = false;
      emit();
    }
  }

  void reset() {
    _uid = null;
    team = null;
    myTeams = [];
    openTeams = [];
    state = LoadState.loading;
    offline = false;
    error = null;
    busy = false;
    emit();
  }
}
