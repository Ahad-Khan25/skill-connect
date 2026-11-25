import '../core/constants.dart';
import '../core/errors.dart';
import '../core/validators.dart';
import '../data/cache_store.dart';
import '../data/repository.dart';
import '../models/models.dart';
import 'base_controller.dart';
import 'profile_controller.dart';

/// My team. state: ready (in a team) | empty (no team yet) | loading | error.
class TeamController extends BaseController {
  TeamController(this._repo, this._cache, this._profile);

  final Repository _repo;
  final CacheStore _cache;
  final ProfileController _profile;
  String? _uid;

  Team? team;
  bool busy = false;

  /// Load cached team instantly; network refresh happens once my profile is known.
  void start(String uid) {
    _uid = uid;
    if (_cache.has(uid, CacheKeys.team)) {
      final cached = _cache.read(uid, CacheKeys.team);
      team = cached is Map ? Team.fromJson(Map<String, dynamic>.from(cached)) : null;
      state = team == null ? LoadState.empty : LoadState.ready;
    } else {
      team = null;
      state = LoadState.loading;
    }
    emit();
  }

  @override
  Future<void> refresh() async {
    final uid = _uid;
    if (uid == null) return;
    final myId = _profile.me?.id;
    if (myId == null) {
      // No profile -> no team. If the profile failed to load, mirror that.
      if (_profile.state == LoadState.error && team == null) {
        state = LoadState.error;
        error = _profile.error;
      } else if (_profile.state == LoadState.empty) {
        team = null;
        state = LoadState.empty;
      }
      emit();
      return;
    }
    if (team == null && state != LoadState.empty) {
      state = LoadState.loading;
      emit();
    }
    try {
      final t = await _repo.fetchMyTeam(myId);
      if (uid != _uid) return;
      team = t;
      offline = false;
      error = null;
      state = t == null ? LoadState.empty : LoadState.ready;
      await _cache.write(uid, CacheKeys.team, t?.toJson());
    } catch (e) {
      final err = friendlyError(e);
      error = err.message;
      if (_cache.has(uid, CacheKeys.team)) {
        offline = err.isNetwork;
        state = team == null ? LoadState.empty : LoadState.ready;
      } else {
        state = LoadState.error;
      }
    }
    emit();
  }

  Future<String?> create(String title, String projectType, List<String> rolesNeeded) async {
    final v = Validators.teamTitle(title) ??
        (kProjectTypes.contains(projectType) ? null : 'Please select a project type') ??
        (rolesNeeded.isEmpty ? 'Pick at least one role you need' : null);
    if (v != null) return v;
    if (_profile.me == null) return 'Please complete your profile first.';
    if (team != null) return 'You are already in a team. Leave it first.';
    return _mutate(() => _repo.createTeam(title.trim(), projectType, rolesNeeded.toSet().toList()));
  }

  /// Leave my team (if I am the owner the team is disbanded).
  Future<String?> leave() async {
    final t = team;
    if (t == null) return 'You are not in a team.';
    return _mutate(() => _repo.leaveTeam(t.id));
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
    state = LoadState.loading;
    offline = false;
    error = null;
    busy = false;
    emit();
  }
}
