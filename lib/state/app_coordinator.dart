import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/cache_store.dart';
import '../data/repository.dart';
import '../models/models.dart';
import 'auth_controller.dart';
import 'discover_controller.dart';
import 'match_controller.dart';
import 'profile_controller.dart';
import 'requests_controller.dart';
import 'team_controller.dart';

/// Creates every controller, wires their dependencies and reacts to
/// sign-in / sign-out:
///  * signed in  -> profile + students load (cache first, then network);
///                  requests + team load once my profile id is known.
///  * signed out -> every controller is reset.
class AppCoordinator {
  AppCoordinator(Repository repo, CacheStore cache)
      : auth = AuthController(repo, cache),
        profile = ProfileController(repo, cache) {
    team = TeamController(repo, cache, profile);
    discover = DiscoverController(repo, cache, profile, team);
    match = MatchController(profile, discover, team);
    requests = RequestsController(repo, cache, profile, team);

    auth.addListener(_onAuth);
    profile.addListener(_onProfile);
    auth.init();
  }

  final AuthController auth;
  final ProfileController profile;
  late final TeamController team;
  late final DiscoverController discover;
  late final MatchController match;
  late final RequestsController requests;

  String? _uid;
  String? _profileKey;

  void _onAuth() {
    final uid = auth.status == AuthStatus.signedIn ? auth.userId : null;
    if (uid == _uid) return;
    _uid = uid;
    _profileKey = null;
    if (uid == null) {
      profile.reset();
      discover.reset();
      team.reset();
      requests.reset();
      return;
    }
    team.start(uid);
    requests.start(uid);
    profile.start(uid);
    discover.start(uid);
  }

  void _onProfile() {
    if (_uid == null) return;
    final key = '${profile.me?.id}|${profile.me == null ? profile.state.name : 'has'}';
    if (key == _profileKey) return;
    _profileKey = key;
    if (profile.state == LoadState.loading && profile.me == null) return;
    team.refresh();
    requests.refresh();
  }

  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<AuthController>.value(value: auth),
        ChangeNotifierProvider<ProfileController>.value(value: profile),
        ChangeNotifierProvider<TeamController>.value(value: team),
        ChangeNotifierProvider<DiscoverController>.value(value: discover),
        ChangeNotifierProvider<MatchController>.value(value: match),
        ChangeNotifierProvider<RequestsController>.value(value: requests),
      ];
}
