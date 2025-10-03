import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentCoursesScreen extends StatelessWidget {
  const StudentCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student/dashboard'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Colors.grey.shade600),
            SizedBox(height: 16),
            Text(
              'My Courses',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This is a placeholder screen for enrolled courses.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              'Features coming soon:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• View enrolled courses'),
            Text('• Course materials'),
            Text('• Assignment submissions'),
            Text('• Course progress tracking'),
          ],
        ),
      ),
    );
  }
}
