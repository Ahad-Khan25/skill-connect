import '../core/errors.dart';
import '../data/cache_store.dart';
import '../data/match_engine.dart';
import '../data/repository.dart';
import '../models/models.dart';
import 'base_controller.dart';
import 'profile_controller.dart';
import 'team_controller.dart';

/// All students + search / filters / sort for the Discover screen.
/// [results] never contains me. state is `empty` when nothing matches.
class DiscoverController extends BaseController {
  DiscoverController(this._repo, this._cache, this._profile, this._team) {
    _profile.addListener(_recompute);
    _team.addListener(_recompute);
  }

  final Repository _repo;
  final CacheStore _cache;
  final ProfileController _profile;
  final TeamController _team;
  String? _uid;

  /// Raw loading state of the student list (before filtering).
  LoadState dataState = LoadState.loading;

  /// Every profile from the backend (including me, flagged isMe).
  List<Profile> all = [];
  List<Profile> results = [];
  String query = '';
  DiscoverFilters filters = const DiscoverFilters();
  SortOption sort = SortOption.bestMatch;

  bool get hasActiveFilters => filters.isActive || query.trim().isNotEmpty;

  Profile? byId(String id) => all.where((p) => p.id == id).firstOrNull;

  Future<void> start(String uid) async {
    _uid = uid;
    final cached = _cache.read(uid, CacheKeys.profiles);
    if (cached is List) {
      all = cached.map((e) => Profile.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      dataState = LoadState.ready;
    } else {
      all = [];
      dataState = LoadState.loading;
    }
    _recompute();
    await refresh();
  }

  @override
  Future<void> refresh() async {
    final uid = _uid;
    if (uid == null) return;
    if (all.isEmpty) {
      dataState = LoadState.loading;
      _recompute();
    }
    try {
      final list = await _repo.fetchProfiles();
      if (uid != _uid) return;
      all = list;
      offline = false;
      error = null;
      dataState = LoadState.ready;
      await _cache.write(uid, CacheKeys.profiles, list.map((p) => p.toJson()).toList());
    } catch (e) {
      final err = friendlyError(e);
      error = err.message;
      if (all.isNotEmpty) {
        offline = err.isNetwork;
        dataState = LoadState.ready;
      } else {
        dataState = LoadState.error;
      }
    }
    _recompute();
  }

  void setQuery(String q) {
    query = q;
    _recompute();
  }

  void setFilters(DiscoverFilters f) {
    filters = f;
    _recompute();
  }

  void setSort(SortOption s) {
    sort = s;
    _recompute();
  }

  void clearFilters() {
    filters = const DiscoverFilters();
    query = '';
    _recompute();
  }

  void _recompute() {
    final me = _profile.me;
    final q = query.trim().toLowerCase();
    final f = filters;
    var list = all.where((p) {
      if (p.isMe || (me != null && p.id == me.id)) return false;
      if (q.isNotEmpty &&
          !p.name.toLowerCase().contains(q) &&
          !p.university.toLowerCase().contains(q) &&
          !p.skills.any((s) => s.toLowerCase().contains(q))) {
        return false;
      }
      if (f.university != null && p.university != f.university) return false;
      if (f.department != null && p.department != f.department) return false;
      if (f.semester != null && p.semester != f.semester) return false;
      if (f.skill != null && !p.skills.contains(f.skill)) return false;
      if (f.projectType != null && p.projectType != f.projectType) return false;
      return true;
    }).toList();

    switch (sort) {
      case SortOption.bestMatch when me != null:
        final activeTeam = _team.team;
        final needed = MatchEngine.neededSkills(me, activeTeam);
        final scores = {
          for (final p in list)
            p.id: MatchEngine.score(me, p, needed: needed, activeTeam: activeTeam).score
        };
        list.sort((a, b) {
          final c = scores[b.id]!.compareTo(scores[a.id]!);
          return c != 0 ? c : a.name.compareTo(b.name);
        });
      case SortOption.semester:
        list.sort((a, b) {
          final c = b.semester.compareTo(a.semester);
          return c != 0 ? c : a.name.compareTo(b.name);
        });
      default:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    results = list;
    state = switch (dataState) {
      LoadState.loading => LoadState.loading,
      LoadState.error => LoadState.error,
      _ => results.isEmpty ? LoadState.empty : LoadState.ready,
    };
    emit();
  }

  void reset() {
    _uid = null;
    all = [];
    results = [];
    query = '';
    filters = const DiscoverFilters();
    sort = SortOption.bestMatch;
    dataState = LoadState.loading;
    state = LoadState.loading;
    offline = false;
    error = null;
    emit();
  }

  @override
  void dispose() {
    _profile.removeListener(_recompute);
    _team.removeListener(_recompute);
    super.dispose();
  }
}
