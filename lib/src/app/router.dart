import 'package:go_router/go_router.dart';
import '../features/mantras/screens/home_screen.dart';
import '../features/mantras/screens/mantra_detail_screen.dart';
import '../features/mantras/screens/create_mantra_screen.dart';
import '../features/session/screens/session_screen.dart';
import '../features/library/screens/library_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../shared/widgets/app_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/library', builder: (_, __) => const LibraryScreen()),
        GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
    GoRoute(
      path: '/mantras/new',
      builder: (_, __) => const CreateMantraScreen(),
    ),
    GoRoute(
      path: '/mantras/:id',
      builder: (_, state) => MantraDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/mantras/:id/edit',
      builder: (_, state) => CreateMantraScreen(editId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/mantras/:id/session',
      builder: (_, state) => SessionScreen(id: state.pathParameters['id']!),
    ),
  ],
);
