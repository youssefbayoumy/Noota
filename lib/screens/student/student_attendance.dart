import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student/dashboard'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code, size: 64, color: Colors.grey.shade600),
            SizedBox(height: 16),
            Text(
              'Attendance QR Code',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This is a placeholder screen for QR code attendance.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              'Features coming soon:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• Generate QR code for attendance'),
            Text('• Show attendance history'),
            Text('• Real-time attendance tracking'),
            Text('• Location verification'),
          ],
        ),
      ),
    );
  }
}
