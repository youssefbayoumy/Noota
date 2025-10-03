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

// User role provider
final userRoleProvider = Provider<UserRole?>((ref) {
  return AuthService.getCurrentUserRole();
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
