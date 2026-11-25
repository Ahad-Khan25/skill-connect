import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Shared bits for every data controller:
/// * [state]   – loading / ready / empty / error (drive the UI from this)
/// * [offline] – true when showing cached data because the network failed
/// * [error]   – friendly message for the error state / snackbars
/// Controllers never throw to the UI.
abstract class BaseController extends ChangeNotifier {
  LoadState state = LoadState.loading;
  bool offline = false;
  String? error;
  bool _disposed = false;

  /// Reload from the network (pull-to-refresh / retry buttons).
  Future<void> refresh();

  /// notifyListeners that is safe after dispose.
  @protected
  void emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
