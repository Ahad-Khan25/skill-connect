import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/data/cache_store.dart';
import 'package:teamup/data/fake_repository.dart';
import 'package:teamup/state/app_coordinator.dart';
import 'package:teamup/ui/app_root.dart';

void main() {
  testWidgets('Responsive mobile layout (360x640) renders all tabs, filter clear & project detail screens with zero overflow',
      (WidgetTester tester) async {
    // Configure compact phone screen size (360x640 logical pixels)
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

    // 1. Auth screen visible on 360x640 with no overflow; scroll if needed and sign in
    final signInBtn = find.text('Sign In to TeamUp');
    await tester.ensureVisible(signInBtn);
    await tester.pumpAndSettle();
    await tester.tap(signInBtn);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    // 2. Smart Matches tab renders with circular score rings & project switcher
    expect(find.text('Smart Matches'), findsOneWidget);
    expect(find.text('ACTIVE PROJECT MATCHING'), findsOneWidget);

    // 3. Switch to Discover tab and verify individual filter apply + "Any (clear)" works!
    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Discover Students'), findsOneWidget);

    // Tap Semester filter pill -> choose '4'
    final semFilter = find.text('Semester');
    await tester.ensureVisible(semFilter);
    await tester.pumpAndSettle();
    await tester.tap(semFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('4').last);
    await tester.pumpAndSettle();
    expect(app.discover.filters.semester, 4);
    expect(find.text('Sem 4'), findsOneWidget);

    // Open Sem 4 dropdown and click 'Any (clear)' -> verify semester filter clears individually!
    await tester.tap(find.text('Sem 4'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Any (clear)').last);
    await tester.pumpAndSettle();
    expect(app.discover.filters.semester, isNull);
    expect(find.text('Semester'), findsOneWidget);

    // 4. Switch to Projects tab -> verify 3 sub-tabs: My Projects, Joined, Open Teams
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(find.textContaining('My Projects'), findsOneWidget);
    expect(find.textContaining('Joined'), findsOneWidget);
    expect(find.textContaining('Open Teams'), findsOneWidget);

    // Tap the first owned project card title ("MediTrack") to open Project Detail screen (edit details & remove member)
    await tester.tap(find.textContaining('MediTrack').first);
    await tester.pumpAndSettle();
    expect(find.text('Edit Project'), findsOneWidget);

    // Pop back to Projects tab and switch to "Joined" sub-tab to verify responsibilities view
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Joined'));
    await tester.pumpAndSettle();
    expect(find.textContaining('MY RESPONSIBILITIES AS'), findsWidgets);

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
