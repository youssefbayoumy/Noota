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

  String get description {
    switch (this) {
      case UserRole.student:
        return 'Enroll in courses, attend sessions, track progress';
      case UserRole.parent:
        return 'Monitor children\'s progress and manage enrollments';
      case UserRole.teacher:
        return 'Create courses, manage sessions, track attendance';
      case UserRole.admin:
        return 'Manage the platform and resolve issues';
    }
  }

  String get arabicDescription {
    switch (this) {
      case UserRole.student:
        return 'التسجيل في الدورات، حضور الجلسات، تتبع التقدم';
      case UserRole.parent:
        return 'مراقبة تقدم الأطفال وإدارة التسجيلات';
      case UserRole.teacher:
        return 'إنشاء الدورات، إدارة الجلسات، تتبع الحضور';
      case UserRole.admin:
        return 'إدارة المنصة وحل المشاكل';
    }
  }

  int get priority {
    switch (this) {
      case UserRole.admin:
        return 4;
      case UserRole.teacher:
        return 3;
      case UserRole.parent:
        return 2;
      case UserRole.student:
        return 1;
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
          'view_course_materials',
          'submit_assignments',
          'view_schedule',
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
          'view_children_attendance',
          'view_children_grades',
          'receive_notifications',
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
          'view_student_profiles',
          'manage_course_materials',
          'send_notifications',
          'view_payment_history',
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
          'manage_platform_settings',
          'view_system_analytics',
          'manage_payment_gateways',
          'handle_support_tickets',
        ];
    }
  }

  List<String> get dashboardRoutes {
    switch (this) {
      case UserRole.student:
        return ['/student/dashboard'];
      case UserRole.parent:
        return ['/parent/dashboard'];
      case UserRole.teacher:
        return ['/teacher/dashboard'];
      case UserRole.admin:
        return ['/admin/dashboard'];
    }
  }

  bool canAccessRoute(String route) {
    return dashboardRoutes.any(
      (dashboardRoute) => route.startsWith(dashboardRoute),
    );
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool hasAnyPermission(List<String> requiredPermissions) {
    return requiredPermissions.any(
      (permission) => permissions.contains(permission),
    );
  }

  bool hasAllPermissions(List<String> requiredPermissions) {
    return requiredPermissions.every(
      (permission) => permissions.contains(permission),
    );
  }
}
