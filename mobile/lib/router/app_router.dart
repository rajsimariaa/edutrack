import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/syllabus/syllabus_screen.dart';
import '../features/syllabus/chapter_screen.dart';
import '../features/syllabus/module_screen.dart';
import '../features/schedule/schedule_screen.dart';
import '../features/tests/tests_screen.dart';
import '../features/tests/test_detail_screen.dart';
import '../features/focus/focus_screen.dart';
import '../features/focus/notes_screen.dart';
import '../features/gamification/gamification_screen.dart';
import '../features/gamification/leaderboard_screen.dart';
import '../features/resources/resources_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/focus/habits_screen.dart';
import '../features/gamification/peer_rooms_screen.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final authRefreshProvider = Provider<AuthRefreshNotifier>((ref) {
  final notifier = AuthRefreshNotifier();
  ref.listen<AuthState>(authProvider, (_, _) => notifier.refresh());
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh = ref.watch(authRefreshProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final location = state.matchedLocation;
      final isOnboarding = location == '/onboarding';
      final isAuthPage = location == '/login' || location == '/register';

      if (isLoading) return null;

      if (!isLoggedIn) {
        return isAuthPage ? null : '/login';
      }

      if (isLoggedIn && authState.profile == null && !isOnboarding) {
        return '/onboarding';
      }

      if (isLoggedIn && authState.profile != null && isOnboarding) {
        return '/home';
      }

      if (isLoggedIn && authState.profile != null && isAuthPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/syllabus',
            builder: (context, state) => const SyllabusScreen(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/tests',
            builder: (context, state) => const TestsScreen(),
          ),
          GoRoute(
            path: '/focus',
            builder: (context, state) => const FocusScreen(),
          ),
          GoRoute(
            path: '/gamification',
            builder: (context, state) => const GamificationScreen(),
          ),
          GoRoute(
            path: '/resources',
            builder: (context, state) => const ResourcesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/focus/habits',
            builder: (context, state) => const HabitsScreen(),
          ),
          GoRoute(
            path: '/profile/peer-rooms',
            builder: (context, state) => const PeerRoomsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/syllabus/modules/:subjectId/:subjectName',
        builder: (context, state) => ModuleScreen(
          subjectId: state.pathParameters['subjectId']!,
          subjectName: Uri.decodeComponent(state.pathParameters['subjectName']!),
        ),
      ),
      GoRoute(
        path: '/syllabus/chapter/:chapterId/:chapterName',
        builder: (context, state) => ChapterScreen(
          chapterId: state.pathParameters['chapterId']!,
          chapterName: Uri.decodeComponent(state.pathParameters['chapterName']!),
        ),
      ),
      GoRoute(
        path: '/syllabus/chapter/:chapterId',
        builder: (context, state) => ChapterScreen(
          chapterId: state.pathParameters['chapterId']!,
        ),
      ),
      GoRoute(
        path: '/tests/:testId',
        builder: (context, state) => TestDetailScreen(
          testId: state.pathParameters['testId']!,
        ),
      ),
      GoRoute(
        path: '/focus/notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/gamification/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
    ],
  );
});

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Syllabus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/syllabus')) return 1;
    if (location.startsWith('/schedule')) return 2;
    if (location.startsWith('/focus')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/syllabus');
        break;
      case 2:
        context.go('/schedule');
        break;
      case 3:
        context.go('/focus');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
