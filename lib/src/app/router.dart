import 'package:go_router/go_router.dart';
import '../core/providers/launch_notifier.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/onboarding/screens/sign_in_screen.dart';
import '../features/onboarding/screens/expectations_screen.dart';
import '../features/mantras/screens/mypractice_screen.dart';
import '../features/mantras/screens/mantra_detail_screen.dart';
import '../features/mantras/screens/create_mantra_screen.dart';
import '../features/mantras/screens/practice_plan_screen.dart';
import '../features/session/screens/session_screen.dart';
import '../features/library/screens/library_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/feedback_screen.dart';
import '../shared/widgets/app_scaffold.dart';

const _onboardingPaths = {'/welcome', '/sign-in', '/expectations'};

final appRouter = GoRouter(
  initialLocation: '/library',
  refreshListenable: launchNotifier,
  redirect: (context, state) {
    if (launchNotifier.isLoading) return null;
    if (!launchNotifier.hasLaunched) {
      if (_onboardingPaths.contains(state.matchedLocation)) return null;
      return '/welcome';
    }
    return null;
  },
  routes: [
    // ── Onboarding (no bottom nav) ───────────────────────────────────────
    GoRoute(path: '/welcome',       builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/sign-in',       builder: (_, __) => const SignInScreen()),
    GoRoute(path: '/expectations',  builder: (_, __) => const ExpectationsScreen()),

    // ── Main shell (3-tab nav) ───────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(path: '/library',    builder: (_, __) => const LibraryScreen()),
        GoRoute(path: '/mypractice', builder: (_, __) => const MyPracticeScreen()),
        GoRoute(path: '/progress',   builder: (_, __) => const ProgressScreen()),
      ],
    ),

    // ── Non-tab full-screen routes ───────────────────────────────────────
    GoRoute(path: '/settings',  builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/feedback',  builder: (_, __) => const FeedbackScreen()),

    GoRoute(path: '/mantras/new',    builder: (_, __) => const CreateMantraScreen()),
    GoRoute(
      path: '/mantras/:id',
      builder: (_, state) => MantraDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/mantras/:id/edit',
      builder: (_, state) => CreateMantraScreen(editId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/mantras/:id/plan',
      builder: (_, state) {
        final modeStr = state.uri.queryParameters['mode'] ?? 'addFromLibrary';
        final mode = PracticePlanMode.values.firstWhere(
          (m) => m.name == modeStr,
          orElse: () => PracticePlanMode.addFromLibrary,
        );
        return PracticePlanScreen(
            mantraId: state.pathParameters['id']!, mode: mode);
      },
    ),
    GoRoute(
      path: '/mantras/:id/plan/edit',
      builder: (_, state) => PracticePlanScreen(
          mantraId: state.pathParameters['id']!,
          mode: PracticePlanMode.edit),
    ),
    GoRoute(
      path: '/mantras/:id/session',
      builder: (_, state) => SessionScreen(id: state.pathParameters['id']!),
    ),
  ],
);
