import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user_role.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    // Wait for 3 seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Check if user is already authenticated
      final authState = ref.read(authStateProvider);
      authState.when(
        data: (data) {
          if (data.session?.user != null) {
            // User is authenticated, redirect to appropriate dashboard
            final userRole = ref.read(userRoleProvider);
            if (userRole != null) {
              // Redirect to appropriate dashboard based on role
              switch (userRole) {
                case UserRole.student:
                  context.go('/student/dashboard');
                  break;
                case UserRole.parent:
                  context.go('/parent/dashboard');
                  break;
                case UserRole.teacher:
                  context.go('/teacher/dashboard');
                  break;
                case UserRole.admin:
                  context.go('/admin/dashboard');
                  break;
              }
            } else {
              context.go('/role-selection');
            }
          } else {
            // User is not authenticated, go to login
            context.go('/login');
          }
        },
        loading: () {
          // Still loading, go to login
          context.go('/login');
        },
        error: (_, __) {
          // Error occurred, go to login
          context.go('/login');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.school, size: 60, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // App Name
            Text(
              'Noota',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Subtitle
            Text(
              'Connecting Students, Parents & Teachers',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),

            const SizedBox(height: 50),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
