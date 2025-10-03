enum UserRole { student, parent, teacher, admin }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get arabicDisplayName {
    switch (this) {
      case UserRole.student:
        return 'طالب';
      case UserRole.parent:
        return 'ولي أمر';
      case UserRole.teacher:
        return 'معلم';
      case UserRole.admin:
        return 'مدير';
    }
  }

  List<String> get permissions {
    switch (this) {
      case UserRole.student:
        return [
          'view_own_profile',
          'enroll_courses',
          'book_sessions',
          'view_attendance',
          'view_grades',
          'post_reviews',
        ];
      case UserRole.parent:
        return [
          'view_own_profile',
          'manage_children',
          'view_children_data',
          'manage_enrollments',
          'manage_payments',
          'view_reports',
          'manage_consent',
          'post_reviews',
        ];
      case UserRole.teacher:
        return [
          'view_own_profile',
          'create_courses',
          'manage_courses',
          'schedule_sessions',
          'take_attendance',
          'manage_grades',
          'view_analytics',
          'manage_payouts',
        ];
      case UserRole.admin:
        return [
          'view_all_data',
          'manage_consent_logs',
          'handle_disputes',
          'manage_refunds',
          'manage_payouts',
          'moderate_content',
          'view_audit_logs',
          'manage_users',
        ];
    }
  }
}
