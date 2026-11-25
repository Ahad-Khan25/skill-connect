import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/data/cache_store.dart';
import 'package:teamup/data/fake_repository.dart';
import 'package:teamup/data/sample_data.dart';
import 'package:teamup/models/models.dart';
import 'package:teamup/state/app_coordinator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Full State & Controller Flow (QA Checklist)', () {
    late FakeRepository repo;
    late CacheStore cache;
    late AppCoordinator app;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = FakeRepository();
      cache = await CacheStore.create();
      app = AppCoordinator(repo, cache);
    });

    test('Sign up -> forced profile setup -> Discover -> Matches -> Requests -> Team -> Persistence', () async {
      // 1. Starts signed out
      expect(app.auth.status, AuthStatus.signedOut);

      // 2. Empty/invalid sign up inputs return friendly validation messages (never crash)
      expect(await app.auth.signUp('', 'bad', '123'), isNotNull);
      expect(await app.auth.signUp('Ali', 'bad-email', '123456'), isNotNull);
      expect(await app.auth.signUp('Ali', 'ali@comsats.edu.pk', '123'), isNotNull);

      // 3. Proper sign up
      final signUpErr = await app.auth.signUp('Ali Khan', 'ali@comsats.edu.pk', 'password123');
      expect(signUpErr, isNull);
      expect(app.auth.status, AuthStatus.signedIn);
      expect(app.auth.signUpName, 'Ali Khan');

      // Wait for async start() listeners to settle
      await Future.delayed(const Duration(milliseconds: 1100));

      // 4. Forced profile setup (new user has no profile yet)
      expect(app.profile.state, LoadState.empty);
      expect(app.profile.hasProfile, isFalse);

      // Empty profile validation check
      final invalidErr = await app.profile.save(Profile(
        name: '',
        department: '',
        semester: 0,
      ));
      expect(invalidErr, isNotNull);

      // Save valid profile (without asking for project requirements during profile setup!)
      final myProfile = Profile(
        name: 'Ali Khan',
        university: 'COMSATS Wah',
        department: 'Computer Science',
        semester: 7,
        skills: ['Flutter', 'Dart', 'Firebase'],
        interests: ['Mobile Apps', 'AI', 'Health Tech'],
        skillsNeeded: ['UI/UX Design', 'Figma', 'Machine Learning'],
        availability: ['Weekends', 'Evenings'],
        workExperience: 'Flutter Intern at Systems Ltd (3 months).',
        bio: 'Building an AI health companion for my FYP.',
      );
      final saveErr = await app.profile.save(myProfile);
      expect(saveErr, isNull);
      expect(app.profile.hasProfile, isTrue);
      expect(app.profile.state, LoadState.ready);
      expect(app.profile.completeness, 1.0);

      // Edit profile later
      expect(
        await app.profile.save(myProfile.copyWith(workExperience: 'Senior Flutter Intern at Systems Ltd.')),
        isNull,
      );
      expect(app.profile.me!.workExperience, 'Senior Flutter Intern at Systems Ltd.');

      // Wait for profile listener to trigger team & requests refresh
      await Future.delayed(const Duration(milliseconds: 1100));

      // 5. Discover: 5 sample profiles, search & filters work
      expect(app.discover.state, LoadState.ready);
      expect(app.discover.results.length, 5);
      expect(app.discover.results.any((p) => p.isMe), isFalse);

      app.discover.setQuery('Fatima');
      expect(app.discover.results.length, 1);
      expect(app.discover.results.first.name, 'Fatima Zahra');

      app.discover.clearFilters();
      app.discover.setFilters(const DiscoverFilters(
        university: 'COMSATS Wah',
        department: 'Software Engineering',
        projectType: 'FYP',
      ));
      expect(app.discover.hasActiveFilters, isTrue);
      expect(
        app.discover.results.every((p) =>
            p.university == 'COMSATS Wah' &&
            p.department == 'Software Engineering' &&
            p.projectType == 'FYP'),
        isTrue,
      );
      app.discover.clearFilters();

      // 6. Smart Match: sorted desc, reasons present, skillGap computed
      expect(app.match.state, LoadState.ready);
      expect(app.match.matches.length, kSampleProfiles.length);
      for (var i = 1; i < app.match.matches.length; i++) {
        expect(app.match.matches[i - 1].score >= app.match.matches[i].score, isTrue);
      }
      expect(app.match.matches.first.reasons, isNotEmpty);
      expect(app.match.skillGap, containsAll(['UI/UX Design', 'Figma', 'Machine Learning']));

      // 7. Requests: 3 seeded received requests exist for new profile
      expect(app.requests.state, LoadState.ready);
      expect(app.requests.received.length, 3);
      expect(app.requests.pendingReceivedCount, 3);

      // Send a request to a student who hasn't sent us one
      final target = app.discover.results.firstWhere((p) => !app.requests.hasPendingTo(p.id));
      expect(await app.requests.send(target.id, '   '), isNotNull); // empty message blocked
      expect(await app.requests.send(target.id, 'Hi! Want to join our FYP team?'), isNull);
      expect(app.requests.sent.length, 1);
      expect(app.requests.sent.first.status, RequestStatus.pending);
      expect(app.requests.hasPendingTo(target.id), isTrue);

      // Cancel the sent request
      final sentId = app.requests.sent.first.id;
      expect(await app.requests.cancel(sentId), isNull);
      expect(app.requests.sent, isEmpty);

      // Reject one received request
      final toReject = app.requests.received.first.id;
      expect(await app.requests.reject(toReject), isNull);
      expect(app.requests.pendingReceivedCount, 2);

      // Accept a received request -> auto-creates team & adds member with matching role
      final toAccept = app.requests.received.firstWhere((r) => r.status == RequestStatus.pending);
      expect(await app.requests.accept(toAccept.id), isNull);
      expect(app.team.state, LoadState.ready);
      expect(app.team.team, isNotNull);
      expect(app.team.team!.members.length, 2);
      expect(app.team.team!.members.any((m) => m.profile.id == toAccept.from.id), isTrue);

      // 8. Reopening app loads cached data immediately
      final appReopened = AppCoordinator(repo, cache);
      expect(appReopened.profile.hasProfile, isTrue);
      expect(appReopened.profile.me!.name, 'Ali Khan');
      expect(appReopened.team.team, isNotNull);
      expect(appReopened.requests.received, isNotEmpty);

      // 9. Leave team (owner disbands) & create multiple custom projects with descriptions & requirements
      expect(await app.team.leave(), isNull);
      expect(app.team.team, isNull);
      expect(app.team.myTeams, isEmpty);

      expect(
        await app.team.create(
          'Smart Health FYP',
          'FYP',
          ['Designer', 'Tester'],
          description: 'AI-driven health monitoring app.',
          requiredSkills: ['Figma', 'UI/UX Design'],
          domainTags: ['Health Tech', 'AI'],
        ),
        isNull,
      );
      expect(app.team.team, isNotNull);
      expect(app.team.team!.title, 'Smart Health FYP');
      expect(app.team.team!.description, 'AI-driven health monitoring app.');
      final topForProject1 = app.match.matches.first.profile.id;

      // Add a second project with completely different requirements (Web/FinTech) and verify matches change
      expect(
        await app.team.create(
          'FinTrack Web App',
          'Semester Project',
          ['Developer'],
          description: 'MERN stack campus finance tracker.',
          requiredSkills: ['React', 'Node.js', 'SQL'],
          domainTags: ['Web Development', 'FinTech'],
        ),
        isNull,
      );
      expect(app.team.myTeams.length, 2);
      expect(app.team.team!.title, 'FinTrack Web App');
      final topForProject2 = app.match.matches.first.profile.id;
      expect(topForProject1 != topForProject2, isTrue);

      // 10. Sign out clears user cache
      final uid = app.auth.userId!;
      await app.auth.signOut();
      expect(app.auth.status, AuthStatus.signedOut);
      expect(cache.has(uid, CacheKeys.me), isFalse);
    });
  });
}
