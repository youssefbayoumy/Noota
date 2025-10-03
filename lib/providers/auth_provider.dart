import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (data) => data.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// User profile provider
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return await AuthService.getUserProfile(user.id);
});

// User role provider (from metadata - fast)
final userRoleProvider = Provider<UserRole?>((ref) {
  return AuthService.getCurrentUserRole();
});

// User role provider (from database - more reliable)
final userRoleFromProfileProvider = FutureProvider<UserRole?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return await AuthService.getUserRoleFromProfile();
});

// Permission checking providers
final hasPermissionProvider = Provider.family<bool, String>((ref, permission) {
  final role = ref.watch(userRoleProvider);
  if (role == null) return false;
  return role.hasPermission(permission);
});

final hasAnyPermissionProvider = Provider.family<bool, List<String>>((
  ref,
  permissions,
) {
  final role = ref.watch(userRoleProvider);
  if (role == null) return false;
  return role.hasAnyPermission(permissions);
});

final hasAllPermissionsProvider = Provider.family<bool, List<String>>((
  ref,
  permissions,
) {
  final role = ref.watch(userRoleProvider);
  if (role == null) return false;
  return role.hasAllPermissions(permissions);
});

// Route access provider
final canAccessRouteProvider = Provider.family<bool, String>((ref, route) {
  final role = ref.watch(userRoleProvider);
  if (role == null) return false;
  return role.canAccessRoute(route);
});

// Role validation provider
final roleValidationProvider = FutureProvider<bool>((ref) async {
  return await AuthService.validateUserRole();
});

// Authentication status provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Loading state provider for auth operations
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error provider
final authErrorProvider = StateProvider<String?>((ref) => null);
