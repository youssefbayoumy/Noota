import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
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
                    'Welcome, ${profile?.firstName ?? 'Teacher'}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your courses and track student progress',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Today's Sessions
          Text(
            'Today\'s Sessions',
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
                    leading: const Icon(Icons.school, color: Colors.blue),
                    title: const Text('Mathematics - Grade 10'),
                    subtitle: const Text('10:00 AM - 11:30 AM'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // TODO: Start session
                      },
                      child: const Text('Start'),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.science, color: Colors.green),
                    title: const Text('Science - Grade 8'),
                    subtitle: const Text('2:00 PM - 3:30 PM'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // TODO: Start session
                      },
                      child: const Text('Start'),
                    ),
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
                subtitle: 'Manage courses',
                color: Colors.grey.shade800,
                onTap: () {
                  context.go('/teacher/courses');
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.qr_code_scanner,
                title: 'Sessions',
                subtitle: 'Manage sessions',
                color: Colors.grey.shade800,
                onTap: () {
                  context.go('/teacher/sessions');
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.grade,
                title: 'Grades',
                subtitle: 'Manage student grades',
                color: Colors.grey.shade800,
                onTap: () {
                  context.go('/teacher/grading');
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.analytics,
                title: 'Analytics',
                subtitle: 'View performance data',
                color: Colors.grey.shade800,
                onTap: () {
                  context.go('/teacher/analytics');
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Roster Health
          Text(
            'Roster Health',
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Attendance %',
                          value: '92%',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Avg Grade',
                          value: '85%',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Active Students',
                          value: '24',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'This Week',
                          value: '12',
                          color: Colors.purple,
                        ),
                      ),
                    ],
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

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
