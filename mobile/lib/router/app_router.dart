import 'dart:async';
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
import '../features/syllabus/topic_detail_screen.dart';
import '../features/syllabus/forum_screen.dart';
import '../features/schedule/schedule_screen.dart';
import '../features/tests/tests_screen.dart';
import '../features/tests/test_detail_screen.dart';
import '../features/tests/mock_exam_screen.dart';
import '../features/tests/daily_quiz_screen.dart';
import '../features/focus/focus_screen.dart';
import '../features/focus/notes_screen.dart';
import '../features/gamification/gamification_screen.dart';
import '../features/gamification/leaderboard_screen.dart';
import '../features/gamification/daily_challenges_screen.dart';
import '../features/resources/resources_screen.dart';
import '../features/resources/formula_sheets_screen.dart';
import '../features/resources/glossary_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/focus/habits_screen.dart';
import '../features/focus/flashcards_screen.dart';
import '../features/gamification/peer_rooms_screen.dart';
import '../features/profile/analytics_screen.dart';
import '../features/profile/exam_checklist_screen.dart';
import '../features/settings/reminder_settings_screen.dart';
import '../features/settings/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(
      ref.read(authProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final location = state.matchedLocation;
      final isOnboarding = location == '/onboarding';
      final isAuthPage = location == '/login' || location == '/register';

      if (isLoading) return null;
      if (!isLoggedIn) return isAuthPage ? null : '/login';
      if (isLoggedIn && authState.profile == null && !isOnboarding) return '/onboarding';
      if (isLoggedIn && authState.profile != null && isOnboarding) return '/home';
      if (isLoggedIn && authState.profile != null && isAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/syllabus', builder: (context, state) => const SyllabusScreen()),
          GoRoute(path: '/schedule', builder: (context, state) => const ScheduleScreen()),
          GoRoute(path: '/tests', builder: (context, state) => const TestsScreen()),
          GoRoute(path: '/focus', builder: (context, state) => const FocusScreen()),
          GoRoute(path: '/gamification', builder: (context, state) => const GamificationScreen()),
          GoRoute(path: '/resources', builder: (context, state) => const ResourcesScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: '/focus/habits', builder: (context, state) => const HabitsScreen()),
          GoRoute(path: '/profile/peer-rooms', builder: (context, state) => const PeerRoomsScreen()),
        ],
      ),
      GoRoute(
        path: '/syllabus/modules/:subjectId/:subjectName',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ModuleScreen(
          subjectId: state.pathParameters['subjectId']!,
          subjectName: Uri.decodeComponent(state.pathParameters['subjectName']!),
        ),
      ),
      GoRoute(
        path: '/syllabus/chapter/:chapterId/:chapterName',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ChapterScreen(
          chapterId: state.pathParameters['chapterId']!,
          chapterName: Uri.decodeComponent(state.pathParameters['chapterName']!),
        ),
      ),
      GoRoute(
        path: '/syllabus/chapter/:chapterId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ChapterScreen(
          chapterId: state.pathParameters['chapterId']!,
        ),
      ),
      GoRoute(
        path: '/syllabus/topic/:topicId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return TopicDetailScreen(
            topicId: state.pathParameters['topicId']!,
            topicName: extras?['topicName'] as String?,
            topicDescription: extras?['topicDescription'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/syllabus/forum/:chapterId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extras = state.extra as String?;
          return ForumScreen(
            chapterId: state.pathParameters['chapterId']!,
            chapterName: extras,
          );
        },
      ),
      GoRoute(
        path: '/tests/:testId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TestDetailScreen(
          testId: state.pathParameters['testId']!,
        ),
      ),
      GoRoute(
        path: '/focus/notes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/focus/flashcards',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FlashcardsScreen(),
      ),
      GoRoute(
        path: '/profile/analytics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/gamification/leaderboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/profile/reminders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReminderSettingsScreen(),
      ),
      GoRoute(
        path: '/resources/formulas',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FormulaSheetsScreen(),
      ),
      GoRoute(
        path: '/resources/glossary',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GlossaryScreen(),
      ),
      GoRoute(
        path: '/tests/mock-exam/:testId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => MockExamScreen(
          testId: state.pathParameters['testId']!,
        ),
      ),
      GoRoute(
        path: '/profile/exam-checklist',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExamChecklistScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/gamification/challenges',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DailyChallengesScreen(),
      ),
      GoRoute(
        path: '/tests/daily-quiz',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DailyQuizScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

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
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
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
      case 0: context.go('/home'); break;
      case 1: context.go('/syllabus'); break;
      case 2: context.go('/schedule'); break;
      case 3: context.go('/focus'); break;
      case 4: context.go('/profile'); break;
    }
  }
}
