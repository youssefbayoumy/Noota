import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';

/// Utility class for role-based UI components and helpers
class RoleUtils {
  /// Get role-specific color scheme (Grayscale theme)
  static Color getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Colors.grey.shade600;
      case UserRole.parent:
        return Colors.grey.shade700;
      case UserRole.teacher:
        return Colors.grey.shade800;
      case UserRole.admin:
        return Colors.black87;
    }
  }

  /// Get role-specific icon
  static IconData getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.parent:
        return Icons.family_restroom;
      case UserRole.teacher:
        return Icons.person;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  /// Get role-specific gradient colors (Grayscale theme)
  static List<Color> getRoleGradient(UserRole role) {
    switch (role) {
      case UserRole.student:
        return [Colors.grey.shade400, Colors.grey.shade600];
      case UserRole.parent:
        return [Colors.grey.shade500, Colors.grey.shade700];
      case UserRole.teacher:
        return [Colors.grey.shade600, Colors.grey.shade800];
      case UserRole.admin:
        return [Colors.grey.shade700, Colors.black87];
    }
  }
}

/// Widget that shows content only if user has specific permission
class PermissionGate extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(hasPermissionProvider(permission));

    if (hasPermission) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget that shows content only if user has any of the specified permissions
class AnyPermissionGate extends ConsumerWidget {
  final List<String> permissions;
  final Widget child;
  final Widget? fallback;

  const AnyPermissionGate({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnyPermission = ref.watch(hasAnyPermissionProvider(permissions));

    if (hasAnyPermission) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget that shows content only if user has all specified permissions
class AllPermissionsGate extends ConsumerWidget {
  final List<String> permissions;
  final Widget child;
  final Widget? fallback;

  const AllPermissionsGate({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAllPermissions = ref.watch(hasAllPermissionsProvider(permissions));

    if (hasAllPermissions) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget that shows content only for specific roles
class RoleGate extends ConsumerWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleGate({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);

    if (userRole != null && allowedRoles.contains(userRole)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Role-specific action button
class RoleActionButton extends ConsumerWidget {
  final String permission;
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;

  const RoleActionButton({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(hasPermissionProvider(permission));

    return ElevatedButton(
      onPressed: hasPermission ? onPressed : null,
      style: style,
      child: child,
    );
  }
}

/// Role-specific navigation drawer item
class RoleDrawerItem extends ConsumerWidget {
  final String permission;
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  const RoleDrawerItem({
    super.key,
    required this.permission,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(hasPermissionProvider(permission));

    if (!hasPermission) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: isSelected,
      onTap: onTap,
    );
  }
}

/// Role-specific card widget
class RoleCard extends ConsumerWidget {
  final UserRole role;
  final Widget child;
  final VoidCallback? onTap;

  const RoleCard({
    super.key,
    required this.role,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = RoleUtils.getRoleGradient(role);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}

/// Role-specific badge widget
class RoleBadge extends StatelessWidget {
  final UserRole role;
  final String text;

  const RoleBadge({super.key, required this.role, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = RoleUtils.getRoleColor(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
