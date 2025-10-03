import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_role.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Header
              Text(
                'Welcome to Private Classes App',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                'Please select your role to continue',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Role Selection Cards
              Expanded(
                child: Column(
                  children: [
                    _buildRoleCard(
                      context,
                      role: UserRole.student,
                      icon: Icons.school,
                      title: 'Student',
                      subtitle:
                          'Enroll in courses, attend sessions, track progress',
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 20),

                    _buildRoleCard(
                      context,
                      role: UserRole.parent,
                      icon: Icons.family_restroom,
                      title: 'Parent',
                      subtitle:
                          'Monitor your child\'s progress and manage enrollments',
                      color: Colors.green,
                    ),

                    const SizedBox(height: 20),

                    _buildRoleCard(
                      context,
                      role: UserRole.teacher,
                      icon: Icons.person,
                      title: 'Teacher',
                      subtitle:
                          'Create courses, manage sessions, track attendance',
                      color: Colors.orange,
                    ),

                    const SizedBox(height: 20),

                    _buildRoleCard(
                      context,
                      role: UserRole.admin,
                      icon: Icons.admin_panel_settings,
                      title: 'Admin',
                      subtitle: 'Manage the platform and resolve issues',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required UserRole role,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.go('/login', extra: role),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
