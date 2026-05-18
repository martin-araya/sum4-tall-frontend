# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Read also: `docs/AGENT_FLUTTER.md` and `docs/DESIGN_PROPOSAL.md`.

---

## Commands

```bash
# Install / update dependencies
flutter pub get

# Generate code after editing any @freezed / @riverpod / @JsonSerializable model
dart run build_runner build --delete-conflicting-outputs

# Run in Chrome (web, port 3000)
flutter run -d chrome --web-port 3000

# Simulate mobile in DevTools: Ctrl+Shift+M after running in Chrome

# Lint (must be clean before commit)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/features/auth/login_test.dart

# Production web build
flutter build web --release --web-renderer canvaskit --tree-shake-icons

# Update golden tests
flutter test --update-goldens
```

---

## Architecture

The app has **two parallel layouts** coexisting right now — the old one is being phased out:

### Legacy layout (phase out)
`lib/main.dart` → `lib/app.dart` → `lib/screens/*` — flat StatefulWidget tree using
`http` + static `ApiService` calls. `lib/mock/mock_data.dart` holds all MVP mock data.
These screens will be removed as each feature moves to the new layout.

### Target layout (new, feature-first)
`lib/main.dart` → `runApp(ProviderScope(child: App()))`.
`lib/app/app.dart` → `MaterialApp.router` wired to `GoRouter`.
Each feature lives under `lib/features/<name>/` with three layers:

```
data/         ← DTOs (@freezed + @JsonSerializable), Dio datasources, repo impl
domain/       ← pure entities, abstract repo interfaces, use cases
presentation/ ← @riverpod AsyncNotifier controllers, ConsumerWidget pages, widgets
```

`domain` must never import `data` or `presentation`.

### Routing
`lib/app/router/app_router.dart` — `GoRouter` with a `ShellRoute` wrapping all
authenticated pages. Auth guard uses a `bool isAuthenticated` flag (TODO: replace with
a Riverpod provider). Shell layout: `AppSidebar (240 px) + Column(AppTopbar, child)`.

Routes: `/login`, `/dashboard`, `/sucursales`, `/sucursales/:id`, `/audits`, `/auditors`.

---

## State management

Riverpod via code generation — always `@riverpod` on an `AsyncNotifier`:

```dart
@riverpod
class AuditsController extends _$AuditsController {
  @override
  Future<List<Auditoria>> build() async =>
      ref.watch(auditRepositoryProvider).getAll();
}

// Widget
class AuditsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(auditsControllerProvider).when(
      loading: () => const AuditsShimmer(),
      error: (e, _) => ErrorCard(message: e.toString()),
      data: (audits) => AuditsList(audits: audits),
    );
  }
}
```

---

## Design tokens

All tokens live under `lib/app/theme/`:

| File | Content |
|---|---|
| `app_colors.dart` | `primary900/800/700`, `accent500/700`, audit-status colors |
| `app_typography.dart` | Inter (UI) + JetBrains Mono (data values) |
| `app_spacing.dart` | xs:4 sm:8 md:12 lg:16 xl:24 xxl:32 xxxl:48 |
| `app_theme.dart` | `AppTheme.light()` — the only place `ThemeData` is built |

Seed color: `primary800 = Color(0xFF1E3A8A)`.
Audit status colors: `completada` → green, `pendiente` → amber, `con_observaciones` → light-blue, `vencida` → **grey** (never red).
Breakpoints: `< 600 px` → `BottomNavBar` (no sidebar); `≥ 600 px` → sidebar 240 px.

---

## Network layer

`Dio` client at `lib/core/network/dio_client.dart` with interceptors for JWT Bearer,
retry, and logging. JWT stored via `shared_preferences`.
`API_URL` injected at build time: `--dart-define=API_URL=http://localhost:8003/api`.
The old static `lib/services/api_service.dart` (uses `http`) is being removed as
features migrate to their own Dio datasources.

---

## Non-negotiable rules

1. Zero `setState` in features — only in ephemeral UI widgets (e.g., `TextEditingController`).
2. Always handle all three `AsyncValue` states: loading, error, data.
3. Zero Spanish strings hardcoded in Dart — all in `lib/l10n/app_es.arb`.
4. Zero `Color(0xFF…)` outside `app_colors.dart`.
5. Zero HTTP calls in widgets.
6. `ListView.builder` for all lists; never `ListView(children:[…])`.
7. Every `IconButton` needs `tooltip:`; custom tap targets need `Semantics`.
8. Run `dart run build_runner build` after every new freezed model.
