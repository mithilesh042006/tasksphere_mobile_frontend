import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// User state class to hold user data and loading state
class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isLoggedIn => user != null;
}

// User provider notifier
class UserNotifier extends StateNotifier<UserState> {
  final AuthService _authService;

  UserNotifier(this._authService) : super(const UserState()) {
    _loadCurrentUser();
  }

  // Load current user from storage
  Future<void> _loadCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        user: null,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Login user
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.login(
        username: username,
        password: password,
      );

      if (result.success && result.user != null) {
        state = state.copyWith(
          user: result.user,
          isLoading: false,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          user: null,
          isLoading: false,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        user: null,
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Register user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String displayName,
    String? bio,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.register(
        username: username,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        displayName: displayName,
      );

      if (result.success && result.user != null) {
        state = state.copyWith(
          user: result.user,
          isLoading: false,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          user: null,
          isLoading: false,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        user: null,
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? avatar,
    bool? isDiscoverable,
  }) async {
    if (state.user == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.updateProfile(
        displayName: displayName,
        bio: bio,
        avatar: avatar,
        isDiscoverable: isDiscoverable,
      );

      if (result.success && result.user != null) {
        state = state.copyWith(
          user: result.user,
          isLoading: false,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Refresh user data from server
  Future<void> refreshUser() async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.fetchUserProfile();
      state = state.copyWith(
        user: user ?? state.user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.logout();
      state = const UserState(isLoading: false);
    } catch (e) {
      // Even if logout fails, clear the user state
      state = UserState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Check if user is authenticated
  Future<bool> checkAuthentication() async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated && state.user != null) {
        // User is no longer authenticated, clear state
        state = const UserState();
      }
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }
}

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// User provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return UserNotifier(authService);
});

// Convenience providers for specific user data
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(userProvider).user;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoggedIn;
});

final userLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoading;
});

final userErrorProvider = Provider<String?>((ref) {
  return ref.watch(userProvider).error;
});

// User display name provider
final userDisplayNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.fullDisplayName ?? 'Guest';
});

// User avatar provider
final userAvatarProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.avatar;
});

// User ID provider
final userIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.userId;
});
