import '../core/constants.dart';
import '../core/errors.dart';
import '../core/validators.dart';
import '../data/cache_store.dart';
import '../data/repository.dart';
import '../models/models.dart';
import 'base_controller.dart';

/// My own profile. state: loading -> ready (has profile) | empty (needs
/// setup) | error (no network AND no cache).
class ProfileController extends BaseController {
  ProfileController(this._repo, this._cache);

  final Repository _repo;
  final CacheStore _cache;
  String? _uid;

  Profile? me;
  bool saving = false;

  bool get hasProfile => me != null;

  /// 0..1 – share of personal profile fields that are filled in.
  double get completeness {
    final p = me;
    if (p == null) return 0;
    final checks = [
      p.name.trim().isNotEmpty,
      p.university.trim().isNotEmpty,
      p.department.isNotEmpty,
      p.semester > 0,
      p.bio.trim().isNotEmpty,
      p.workExperience.trim().isNotEmpty,
      p.skills.isNotEmpty,
      p.interests.isNotEmpty,
      p.availability.isNotEmpty,
      p.skills.length >= 3,
    ];
    return checks.where((c) => c).length / checks.length;
  }

  /// Names of the fields still missing (for the completeness meter).
  List<String> get missingFields {
    final p = me;
    if (p == null) return ['Profile'];
    return [
      if (p.bio.trim().isEmpty) 'Bio',
      if (p.workExperience.trim().isEmpty) 'Work experience',
      if (p.skills.length < 3) 'At least 3 skills',
      if (p.interests.isEmpty) 'Interests',
      if (p.availability.isEmpty) 'Availability',
    ];
  }

  /// Called by the app coordinator after sign-in.
  Future<void> start(String uid) async {
    _uid = uid;
    final cached = _cache.read(uid, CacheKeys.me);
    if (cached is Map) {
      me = Profile.fromJson(Map<String, dynamic>.from(cached))..isMe = true;
      state = LoadState.ready;
    } else {
      me = null;
      state = LoadState.loading;
    }
    emit();
    await refresh();
  }

  @override
  Future<void> refresh() async {
    final uid = _uid;
    if (uid == null) return;
    if (me == null) {
      state = LoadState.loading;
      emit();
    }
    try {
      final p = await _repo.fetchMyProfile();
      if (uid != _uid) return; // user changed meanwhile
      me = p?..isMe = true;
      offline = false;
      error = null;
      state = p == null ? LoadState.empty : LoadState.ready;
      if (p != null) await _cache.write(uid, CacheKeys.me, p.toJson());
    } catch (e) {
      final err = friendlyError(e);
      error = err.message;
      if (me != null) {
        offline = err.isNetwork;
        state = LoadState.ready;
      } else {
        state = LoadState.error;
      }
    }
    emit();
  }

  /// Validates and saves (create or update). Returns an error or null.
  Future<String?> save(Profile p) async {
    final v = validate(p);
    if (v != null) return v;
    final uid = _uid;
    if (uid == null) return 'Your session has expired. Please sign in again.';
    saving = true;
    emit();
    try {
      final saved = await _repo.saveMyProfile(p);
      me = saved..isMe = true;
      state = LoadState.ready;
      offline = false;
      error = null;
      await _cache.write(uid, CacheKeys.me, saved.toJson());
      return null;
    } catch (e) {
      return friendlyError(e).message;
    } finally {
      saving = false;
      emit();
    }
  }

  /// Returns the first validation problem, or null.
  static String? validate(Profile p) {
    return Validators.name(p.name) ??
        (kDepartments.contains(p.department) ? null : 'Please select your department') ??
        (kSemesters.contains(p.semester) ? null : 'Please select your semester') ??
        (p.skills.isEmpty ? 'Please pick at least one skill' : null) ??
        (p.interests.isEmpty ? 'Please pick at least one interest' : null) ??
        (p.availability.isEmpty ? 'Please select your availability' : null) ??
        Validators.bio(p.bio);
  }

  void reset() {
    _uid = null;
    me = null;
    state = LoadState.loading;
    offline = false;
    error = null;
    saving = false;
    emit();
  }
}
