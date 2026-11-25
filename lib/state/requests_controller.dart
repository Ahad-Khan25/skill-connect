import '../core/errors.dart';
import '../core/validators.dart';
import '../data/cache_store.dart';
import '../data/repository.dart';
import '../models/models.dart';
import 'base_controller.dart';
import 'profile_controller.dart';
import 'team_controller.dart';

/// Sent / received team requests. state is `empty` when both lists are empty.
class RequestsController extends BaseController {
  RequestsController(this._repo, this._cache, this._profile, this._team);

  final Repository _repo;
  final CacheStore _cache;
  final ProfileController _profile;
  final TeamController _team;
  String? _uid;

  List<TeamRequest> _all = [];
  final Set<String> _busy = {};

  List<TeamRequest> get sent => _all.where((r) => r.isSent).toList();
  List<TeamRequest> get received => _all.where((r) => !r.isSent).toList();

  int get pendingReceivedCount => received.where((r) => r.status == RequestStatus.pending).length;

  /// True while an accept/reject/cancel/send for this id is in flight.
  bool isBusy(String id) => _busy.contains(id);

  /// True if there is already a pending request between me and this student.
  bool hasPendingTo(String profileId) => _all.any((r) =>
      r.status == RequestStatus.pending && (r.to.id == profileId || r.from.id == profileId));

  /// True if I already have a pending application/invitation for [teamId].
  bool hasPendingForTeam(String teamId) =>
      _all.any((r) => r.status == RequestStatus.pending && r.teamId == teamId);

  void start(String uid) {
    _uid = uid;
    final cached = _cache.read(uid, CacheKeys.requests);
    if (cached is List) {
      _all = cached.map((e) => TeamRequest.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      _setReadyState();
    } else {
      _all = [];
      state = LoadState.loading;
    }
    emit();
  }

  void _setReadyState() => state = _all.isEmpty ? LoadState.empty : LoadState.ready;

  @override
  Future<void> refresh() async {
    final uid = _uid;
    if (uid == null) return;
    final myId = _profile.me?.id;
    if (myId == null) {
      if (_profile.state == LoadState.error && _all.isEmpty) {
        state = LoadState.error;
        error = _profile.error;
      } else if (_profile.state == LoadState.empty) {
        _all = [];
        state = LoadState.empty;
      }
      emit();
      return;
    }
    if (_all.isEmpty && state != LoadState.empty) {
      state = LoadState.loading;
      emit();
    }
    try {
      final list = await _repo.fetchRequests(myId);
      if (uid != _uid) return;
      _all = list;
      offline = false;
      error = null;
      _setReadyState();
      await _cache.write(uid, CacheKeys.requests, list.map((r) => r.toJson()).toList());
    } catch (e) {
      final err = friendlyError(e);
      error = err.message;
      if (_cache.has(uid, CacheKeys.requests)) {
        offline = err.isNetwork;
        _setReadyState();
      } else {
        state = LoadState.error;
      }
    }
    emit();
  }

  Future<String?> send(String toProfileId, String message, {String? forTeamId}) async {
    final v = Validators.requestMessage(message);
    if (v != null) return v;
    final me = _profile.me;
    if (me == null) return 'Please complete your profile first.';
    if (toProfileId == me.id) return 'You cannot send a request to yourself.';
    if (hasPendingTo(toProfileId)) return 'There is already a pending request with this student.';
    if (forTeamId == null && (_team.team?.members.any((m) => m.profile.id == toProfileId) ?? false)) {
      return 'This student is already in your active project team.';
    }
    // If forTeamId is provided (e.g. applying to an open team), use it;
    // otherwise if I own the active team, invite them to my active project.
    final teamId = forTeamId ?? ((_team.team?.iAmOwner ?? false) ? _team.team!.id : null);
    return _mutate(toProfileId, () => _repo.sendRequest(toProfileId, message.trim(), teamId: teamId));
  }

  /// Apply to join an open team posted by another student.
  Future<String?> applyToTeam(Team targetTeam, String message) async {
    final owner = targetTeam.owner?.profile ?? targetTeam.members.firstOrNull?.profile;
    if (owner == null) return 'Team owner not found.';
    final me = _profile.me;
    if (me == null) return 'Please complete your profile first.';
    if (targetTeam.hasMember(me.id)) return 'You are already a member of this team.';
    if (hasPendingForTeam(targetTeam.id) || hasPendingTo(owner.id)) {
      return 'You already have a pending application for this team.';
    }
    return send(owner.id, message, forTeamId: targetTeam.id);
  }

  Future<String?> accept(String id) =>
      _mutate(id, () => _repo.acceptRequest(id), refreshTeam: true);

  Future<String?> reject(String id) => _mutate(id, () => _repo.rejectRequest(id));

  Future<String?> cancel(String id) => _mutate(id, () => _repo.cancelRequest(id));

  Future<String?> _mutate(String key, Future<void> Function() op, {bool refreshTeam = false}) async {
    if (_busy.contains(key)) return 'Please wait…';
    _busy.add(key);
    emit();
    try {
      await op();
      await Future.wait([refresh(), if (refreshTeam) _team.refresh()]);
      return null;
    } catch (e) {
      return friendlyError(e).message;
    } finally {
      _busy.remove(key);
      emit();
    }
  }

  void reset() {
    _uid = null;
    _all = [];
    _busy.clear();
    state = LoadState.loading;
    offline = false;
    error = null;
    emit();
  }
}
