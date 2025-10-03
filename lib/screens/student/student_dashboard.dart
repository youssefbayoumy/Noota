import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                context.go('/role-selection');
              }
            },
          ),
        ],
      ),
      body: userProfile.when(
        data: (profile) => _buildDashboard(context, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${profile?.firstName ?? 'Student'}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to continue your learning journey?',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildActionCard(
                context,
                icon: Icons.school,
                title: 'My Courses',
                subtitle: 'View enrolled courses',
                color: Colors.grey.shade600,
                onTap: () {
                  context.go('/student/courses');
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.qr_code,
                title: 'Attendance QR',
                subtitle: 'Show QR for attendance',
                color: Colors.grey.shade600,
                onTap: () {
                  context.go('/student/attendance');
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.calendar_today,
                title: 'Sessions',
                subtitle: 'View upcoming sessions',
                color: Colors.grey.shade600,
                onTap: () {
                  context.go('/student/sessions');
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.assessment,
                title: 'Performance',
                subtitle: 'View grades & progress',
                color: Colors.grey.shade600,
                onTap: () {
                  context.go('/student/performance');
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: const Text('Attendance marked'),
                    subtitle: const Text('Math Class - 2 hours ago'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.grade, color: Colors.blue),
                    title: const Text('New grade posted'),
                    subtitle: const Text('Science Quiz - 1 day ago'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.school, color: Colors.orange),
                    title: const Text('Course enrolled'),
                    subtitle: const Text('English Literature - 3 days ago'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
