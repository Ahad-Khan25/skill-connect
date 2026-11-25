import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env.dart';
import 'data/cache_store.dart';
import 'data/fake_repository.dart';
import 'data/repository.dart';
import 'data/supabase_repository.dart';
import 'state/app_coordinator.dart';
import 'ui/app_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Repository repo;
  if (kUseFakeBackend) {
    repo = FakeRepository();
  } else {
    // Restores the persisted session (if any) before the first frame.
    await Supabase.initialize(url: kSupabaseUrl, publishableKey: kSupabaseAnonKey);
    repo = SupabaseRepository();
  }
  final cache = await CacheStore.create();
  final app = AppCoordinator(repo, cache);

  runApp(MultiProvider(providers: app.providers, child: const AppRoot()));
}
