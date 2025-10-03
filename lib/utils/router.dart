import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../models/user_role.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/student/student_courses.dart';
import '../screens/student/student_attendance.dart';
import '../screens/student/student_sessions.dart';
import '../screens/student/student_performance.dart';
import '../screens/parent/parent_dashboard.dart';
import '../screens/parent/parent_enrollments.dart';
import '../screens/parent/parent_reports.dart';
import '../screens/parent/parent_payments.dart';
import '../screens/parent/parent_alerts.dart';
import '../screens/teacher/teacher_dashboard.dart';
import '../screens/teacher/teacher_courses.dart';
import '../screens/teacher/teacher_sessions.dart';
import '../screens/teacher/teacher_grading.dart';
import '../screens/teacher/teacher_analytics.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_users.dart';
import '../screens/admin/admin_consent.dart';
import '../screens/admin/admin_disputes.dart';
import '../screens/admin/admin_analytics.dart';

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

      // Redirect based on user role with enhanced security
      if (userRole != null) {
        final currentPath = state.uri.path;

        // Check if user can access the current route
        if (!userRole.canAccessRoute(currentPath)) {
          // Redirect to appropriate dashboard if accessing unauthorized route
          return userRole.dashboardRoutes.first;
        }

        // If accessing root or unauthorized route, redirect to dashboard
        if (currentPath == '/' || !userRole.canAccessRoute(currentPath)) {
          return userRole.dashboardRoutes.first;
        }

        // Allow access to current route
        return null;
      }

      // If no role found, redirect to role selection
      return '/role-selection';
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
        builder: (context, state) => const LoginScreen(),
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
      GoRoute(
        path: '/student/courses',
        builder: (context, state) => const StudentCoursesScreen(),
      ),
      GoRoute(
        path: '/student/attendance',
        builder: (context, state) => const StudentAttendanceScreen(),
      ),
      GoRoute(
        path: '/student/sessions',
        builder: (context, state) => const StudentSessionsScreen(),
      ),
      GoRoute(
        path: '/student/performance',
        builder: (context, state) => const StudentPerformanceScreen(),
      ),

      // Parent Routes
      GoRoute(
        path: '/parent/dashboard',
        builder: (context, state) => const ParentDashboard(),
      ),
      GoRoute(
        path: '/parent/enrollments',
        builder: (context, state) => const ParentEnrollmentsScreen(),
      ),
      GoRoute(
        path: '/parent/reports',
        builder: (context, state) => const ParentReportsScreen(),
      ),
      GoRoute(
        path: '/parent/payments',
        builder: (context, state) => const ParentPaymentsScreen(),
      ),
      GoRoute(
        path: '/parent/alerts',
        builder: (context, state) => const ParentAlertsScreen(),
      ),

      // Teacher Routes
      GoRoute(
        path: '/teacher/dashboard',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/teacher/courses',
        builder: (context, state) => const TeacherCoursesScreen(),
      ),
      GoRoute(
        path: '/teacher/sessions',
        builder: (context, state) => const TeacherSessionsScreen(),
      ),
      GoRoute(
        path: '/teacher/grading',
        builder: (context, state) => const TeacherGradingScreen(),
      ),
      GoRoute(
        path: '/teacher/analytics',
        builder: (context, state) => const TeacherAnalyticsScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/consent',
        builder: (context, state) => const AdminConsentScreen(),
      ),
      GoRoute(
        path: '/admin/disputes',
        builder: (context, state) => const AdminDisputesScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalyticsScreen(),
      ),
    ],
  );
});
