import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Get current user
  static User? get currentUser => _client.auth.currentUser;

  // Get current user stream
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required UserRole role,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': role.name,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      },
    );

    if (response.user != null) {
      // Create user profile in database
      await _createUserProfile(
        response.user!,
        role,
        firstName,
        lastName,
        phone,
      );
    }

    return response;
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with OTP
  static Future<void> signInWithOtp({required String email}) async {
    await _client.auth.signInWithOtp(email: email);
  }

  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Update password
  static Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  // Get user profile
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Update user profile
  static Future<UserModel?> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final response = await _client
          .from('profiles')
          .update({
            'first_name': firstName,
            'last_name': lastName,
            'phone': phone,
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }

  // Create user profile in database
  static Future<void> _createUserProfile(
    User user,
    UserRole role,
    String? firstName,
    String? lastName,
    String? phone,
  ) async {
    try {
      await _client.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'role': role.name,
        'is_active': true,
        'is_email_verified': false,
        'is_phone_verified': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  // Check if user has permission
  static bool hasPermission(String permission) {
    final role = getCurrentUserRole();
    if (role == null) return false;
    return role.hasPermission(permission);
  }

  // Check if user has any of the required permissions
  static bool hasAnyPermission(List<String> permissions) {
    final role = getCurrentUserRole();
    if (role == null) return false;
    return role.hasAnyPermission(permissions);
  }

  // Check if user has all required permissions
  static bool hasAllPermissions(List<String> permissions) {
    final role = getCurrentUserRole();
    if (role == null) return false;
    return role.hasAllPermissions(permissions);
  }

  // Get current user role
  static UserRole? getCurrentUserRole() {
    final user = currentUser;
    if (user == null) return null;

    final roleString = user.userMetadata?['role'] as String?;
    if (roleString == null) return null;

    return UserRole.values.firstWhere(
      (r) => r.name == roleString,
      orElse: () => UserRole.student,
    );
  }

  // Get user role from profile (more reliable than metadata)
  static Future<UserRole?> getUserRoleFromProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final profile = await getUserProfile(user.id);
      return profile?.role;
    } catch (e) {
      print('Error getting user role from profile: $e');
      return null;
    }
  }

  // Check if user can access a specific route
  static bool canAccessRoute(String route) {
    final role = getCurrentUserRole();
    if (role == null) return false;
    return role.canAccessRoute(route);
  }

  // Get user's highest priority role (for users with multiple roles)
  static UserRole? getHighestPriorityRole(List<UserRole> roles) {
    if (roles.isEmpty) return null;
    return roles.reduce((a, b) => a.priority > b.priority ? a : b);
  }

  // Validate user role against database
  static Future<bool> validateUserRole() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final profile = await getUserProfile(user.id);
      if (profile == null) return false;

      final metadataRole = user.userMetadata?['role'] as String?;
      return metadataRole == profile.role.name;
    } catch (e) {
      print('Error validating user role: $e');
      return false;
    }
  }
}
