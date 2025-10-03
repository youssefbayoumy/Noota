import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../models/user_role.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/parent/parent_dashboard.dart';
import '../screens/teacher/teacher_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final userRole = ref.read(userRoleProvider);

      // Show splash screen while loading
      if (authState.isLoading) {
        return '/splash';
      }

      // Redirect to role selection if not authenticated
      if (!isAuthenticated) {
        if (state.uri.path == '/splash') return null;
        return '/role-selection';
      }

      // Redirect based on user role
      if (userRole != null) {
        switch (userRole) {
          case UserRole.student:
            if (state.uri.path.startsWith('/student')) return null;
            return '/student/dashboard';
          case UserRole.parent:
            if (state.uri.path.startsWith('/parent')) return null;
            return '/parent/dashboard';
          case UserRole.teacher:
            if (state.uri.path.startsWith('/teacher')) return null;
            return '/teacher/dashboard';
          case UserRole.admin:
            if (state.uri.path.startsWith('/admin')) return null;
            return '/admin/dashboard';
        }
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.extra as UserRole?;
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          final role = state.extra as UserRole?;
          return SignupScreen(role: role);
        },
      ),

      // Student Routes
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentDashboard(),
      ),

      // Parent Routes
      GoRoute(
        path: '/parent/dashboard',
        builder: (context, state) => const ParentDashboard(),
      ),

      // Teacher Routes
      GoRoute(
        path: '/teacher/dashboard',
        builder: (context, state) => const TeacherDashboard(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
  );
});
