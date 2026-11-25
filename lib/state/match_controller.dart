import '../data/match_engine.dart';
import '../models/models.dart';
import 'base_controller.dart';
import 'discover_controller.dart';
import 'profile_controller.dart';
import 'team_controller.dart';

/// Best Matches: derived from my profile + all students + my team using the
/// pure [MatchEngine]. Recomputes automatically whenever any input changes.
class MatchController extends BaseController {
  MatchController(this._profile, this._discover, this._team) {
    _profile.addListener(_recompute);
    _discover.addListener(_recompute);
    _team.addListener(_recompute);
    _recompute();
  }

  final ProfileController _profile;
  final DiscoverController _discover;
  final TeamController _team;

  List<MatchResult> matches = [];
  Map<String, MatchResult> _byId = {};

  /// Score for any profile (computed on the fly if not in [matches],
  /// e.g. a team member or request sender). Null if I have no profile.
  MatchResult? matchFor(String profileId) {
    final hit = _byId[profileId];
    if (hit != null) return hit;
    final me = _profile.me;
    final p = _discover.byId(profileId);
    if (me == null || p == null) return null;
    return MatchEngine.score(me, p, needed: MatchEngine.neededSkills(me, _team.team));
  }

  /// Needed skills nobody on my team (including me) covers.
  List<String> get skillGap {
    final me = _profile.me;
    return me == null ? [] : MatchEngine.skillGap(me, _team.team);
  }

  /// All skills I am looking for (profile + open team roles).
  List<String> get neededSkills {
    final me = _profile.me;
    return me == null ? [] : MatchEngine.neededSkills(me, _team.team).toList();
  }

  @override
  Future<void> refresh() async {
    await Future.wait([_discover.refresh(), _team.refresh()]);
  }

  void _recompute() {
    final me = _profile.me;
    offline = _discover.offline;
    error = _discover.error;
    if (me == null) {
      matches = [];
      _byId = {};
      state = _profile.state == LoadState.error ? LoadState.error : (_profile.state == LoadState.loading ? LoadState.loading : LoadState.empty);
      emit();
      return;
    }
    matches = MatchEngine.rank(me, _discover.all, _team.team);
    _byId = {for (final m in matches) m.profile.id: m};
    state = switch (_discover.dataState) {
      LoadState.loading => LoadState.loading,
      LoadState.error => LoadState.error,
      _ => matches.isEmpty ? LoadState.empty : LoadState.ready,
    };
    emit();
  }

  @override
  void dispose() {
    _profile.removeListener(_recompute);
    _discover.removeListener(_recompute);
    _team.removeListener(_recompute);
    super.dispose();
  }
}
