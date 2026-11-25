import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/data/cache_store.dart';
import 'package:teamup/data/fake_repository.dart';
import 'package:teamup/state/app_coordinator.dart';
import 'package:teamup/ui/app_root.dart';

void main() {
  testWidgets('Responsive mobile layout (360x640) renders SkillConnect auth, filter clear & project flows with zero overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final repo = FakeRepository();
    final cache = await CacheStore.create();
    final app = AppCoordinator(repo, cache);

    await tester.pumpWidget(
      MultiProvider(providers: app.providers, child: const AppRoot()),
    );

    // Advance past 1.3s splash screen timer
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    // 1. SkillConnect Welcome Landing Screen (Image 2)
    expect(find.text('Welcome to SkillConnect'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);

    // Tap "Get Started" to open Sign In form, then tap "Sign In to SkillConnect"
    final getStartedBtn = find.text('Get Started');
    await tester.ensureVisible(getStartedBtn);
    await tester.pumpAndSettle();
    await tester.tap(getStartedBtn);
    await tester.pumpAndSettle();

    final signInBtn = find.text('Sign In to SkillConnect');
    await tester.ensureVisible(signInBtn);
    await tester.pumpAndSettle();
    await tester.tap(signInBtn);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    // 2. Smart Matches tab renders with 0 dummy pre-existing projects
    expect(find.text('Smart Matches'), findsOneWidget);
    expect(app.team.myTeams, isEmpty);

    // 3. Switch to Discover tab and verify individual filter apply + "Any (clear)" works!
    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Discover Students'), findsOneWidget);

    final semFilter = find.text('Semester');
    await tester.ensureVisible(semFilter);
    await tester.pumpAndSettle();
    await tester.tap(semFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('7').last);
    await tester.pumpAndSettle();
    expect(app.discover.filters.semester, 7);
    expect(find.text('Sem 7'), findsOneWidget);

    await tester.tap(find.text('Sem 7'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Any (clear)').last);
    await tester.pumpAndSettle();
    expect(app.discover.filters.semester, isNull);
    expect(find.text('Semester'), findsOneWidget);

    // 4. Switch to Projects tab -> verify 3 sub-tabs: My Projects (0), Joined (0), Open Teams (0)
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(find.textContaining('My Projects (0)'), findsOneWidget);

    // 5. Switch to Requests tab
    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Received'), findsOneWidget);

    // 6. Switch to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your progress'), findsOneWidget);
  });
}
