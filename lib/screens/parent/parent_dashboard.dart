import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class ParentDashboard extends ConsumerWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
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
                    'Welcome, ${profile?.firstName ?? 'Parent'}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor your children\'s progress and manage their education',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Children Overview
          Text(
            'Your Children',
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
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.person, color: Colors.blue),
                    ),
                    title: const Text('Ahmed Mohamed'),
                    subtitle: const Text('Grade 10 - 3 courses enrolled'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to child details
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: const Icon(Icons.person, color: Colors.green),
                    ),
                    title: const Text('Fatma Ali'),
                    subtitle: const Text('Grade 8 - 2 courses enrolled'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // TODO: Navigate to child details
                    },
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
                title: 'Enrollments',
                subtitle: 'Manage course enrollments',
                color: Colors.grey.shade700,
                onTap: () {
                  context.go('/parent/enrollments');
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.assessment,
                title: 'Reports',
                subtitle: 'View progress reports',
                color: Colors.grey.shade700,
                onTap: () {
                  context.go('/parent/reports');
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.payment,
                title: 'Payments',
                subtitle: 'Manage payments',
                color: Colors.grey.shade700,
                onTap: () {
                  context.go('/parent/payments');
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.notifications,
                title: 'Alerts',
                subtitle: 'View notifications',
                color: Colors.grey.shade700,
                onTap: () {
                  context.go('/parent/alerts');
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Recent Activity Feed
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
                    title: const Text('Ahmed attended Math class'),
                    subtitle: const Text('2 hours ago'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.grade, color: Colors.blue),
                    title: const Text('New grade for Fatma'),
                    subtitle: const Text('Science Quiz - 1 day ago'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.payment, color: Colors.orange),
                    title: const Text('Payment processed'),
                    subtitle: const Text('English course - 2 days ago'),
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
