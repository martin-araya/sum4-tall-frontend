import 'package:flutter/foundation.dart';

/// Notifies [GoRouter]'s refreshListenable when auth state changes.
///
/// Call [notifyAuthChange] after login or logout so the router
/// re-evaluates its redirect and navigates accordingly.
class AuthStateNotifier extends ChangeNotifier {
  void notifyAuthChange() => notifyListeners();
}

/// Global singleton consumed by [goRouter] and any widget that triggers
/// an auth state change (login, logout).
final AuthStateNotifier authStateNotifier = AuthStateNotifier();
