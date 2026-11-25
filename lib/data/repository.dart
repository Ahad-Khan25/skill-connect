import '../models/models.dart';

/// Everything the app needs from a backend. Implemented by
/// [SupabaseRepository] (real) and [FakeRepository] (in-memory demo data).
/// All methods throw [AppException] with a friendly message on failure.
abstract class Repository {
  // ---- auth ----
  /// Id of the signed-in auth user, or null.
  String? get currentUserId;
  String? get currentEmail;

  /// Name given at sign-up (used to prefill profile setup).
  String? get signUpName;

  /// Emits whenever the auth session changes (true = signed in).
  Stream<bool> get authChanges;

  /// Returns true if a session was created; false if email confirmation is required.
  Future<bool> signUp(String name, String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> signOut();

  // ---- profiles ----
  /// My profile, or null if I haven't completed setup.
  Future<Profile?> fetchMyProfile();
  Future<Profile> saveMyProfile(Profile p);

  /// All student profiles (including mine, flagged with isMe).
  Future<List<Profile>> fetchProfiles();

  // ---- requests ----
  /// Requests I sent or received (cancelled ones excluded), newest first.
  Future<List<TeamRequest>> fetchRequests(String myProfileId);
  Future<void> sendRequest(String toProfileId, String message, {String? teamId});
  Future<void> acceptRequest(String id);
  Future<void> rejectRequest(String id);
  Future<void> cancelRequest(String id);

  // ---- team ----
  /// The team I belong to (owned team preferred), or null.
  Future<Team?> fetchMyTeam(String myProfileId);
  Future<void> createTeam(String title, String projectType, List<String> rolesNeeded);
  Future<void> leaveTeam(String teamId);
}
