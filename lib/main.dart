import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/tasks/task_list_screen.dart';
import 'screens/tasks/task_create_screen.dart';
import 'screens/tasks/task_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';

import 'providers/user_provider.dart';
import 'utils/theme.dart';
import 'test_search_widget.dart';
import 'debug/user_state_debug.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  await SharedPreferences.getInstance();

  runApp(
    const ProviderScope(
      child: TaskSphereApp(),
    ),
  );
}

class TaskSphereApp extends ConsumerWidget {
  const TaskSphereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user state to show loading screen during initial load
    final userState = ref.watch(userProvider);

    // Show loading screen while determining authentication state
    if (userState.isLoading) {
      return MaterialApp(
        title: 'TaskSphere',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading TaskSphere...'),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'TaskSphere',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _createRouter(ref),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Router configuration function
GoRouter _createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      // Authentication routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app routes
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/tasks/create',
        name: 'create-task',
        builder: (context, state) => const TaskCreateScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        name: 'task-detail',
        builder: (context, state) {
          final taskId = int.parse(state.pathParameters['id']!);
          return TaskDetailScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/test-search',
        name: 'test-search',
        builder: (context, state) => const TestSearchWidget(),
      ),
      GoRoute(
        path: '/debug-user',
        name: 'debug-user',
        builder: (context, state) => const UserStateDebugWidget(),
      ),
    ],
    redirect: (context, state) async {
      // Wait for user state to be loaded before making routing decisions
      final userState = ref.read(userProvider);

      // Debug logging
      print(
          'Router redirect: ${state.matchedLocation}, loading: ${userState.isLoading}, authenticated: ${userState.isLoggedIn}');

      // If still loading, don't redirect yet
      if (userState.isLoading) {
        print('Router: Still loading, not redirecting');
        return null;
      }

      final isAuthenticated = userState.isLoggedIn;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');

      if (!isAuthenticated && !isAuthRoute) {
        print('Router: Not authenticated, redirecting to login');
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        print(
            'Router: Authenticated but on auth route, redirecting to dashboard');
        return '/dashboard';
      }

      print('Router: No redirect needed');
      return null;
    },
  );
}
