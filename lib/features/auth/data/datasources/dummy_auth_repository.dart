import 'dart:async';

import 'package:demo4/features/auth/data/repositories/auth_repository.dart';

/// Concrete implementation of AuthRepository using dummy data.
///
/// This implementation is used for development and testing.
/// It will be replaced with a real implementation that communicates
/// with the Java backend microservices.
///
/// Dummy credentials:
/// - Email: admin@craftedge.local
/// - Password: password
class DummyAuthRepository implements AuthRepository {
  // Simulate delay for network requests
  static const _simulatedDelay = Duration(milliseconds: 1500);

  // Dummy credentials
  static const _dummyEmail = 'admin@craftedge.local';
  static const _dummyPassword = 'password';

  // Dummy token (in real app, would be received from backend)
  static const _dummyToken = 'dummy_jwt_token_xyz123';

  // Mock session state
  String? _currentToken;
  Map<String, dynamic>? _currentUser;

  @override
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(_simulatedDelay);

    // Validate credentials (dummy check)
    if (email == _dummyEmail && password == _dummyPassword) {
      // Simulate token storage
      _currentToken = _dummyToken;
      _currentUser = {
        'id': 'emp_001',
        'email': email,
        'name': 'Admin User',
        'department': 'Human Resources',
        'role': 'Admin',
        'createdAt': DateTime.now().toString(),
      };
      return true;
    }

    // Invalid credentials
    _currentToken = null;
    _currentUser = null;
    return false;
  }

  @override
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Clear session
    _currentToken = null;
    _currentUser = null;
  }

  @override
  Future<bool> isLoggedIn() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Check if we have a token
    return _currentToken != null;
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (_currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    return _currentUser!;
  }

  @override
  Future<void> refreshToken() async {
    // Simulate network delay
    await Future.delayed(_simulatedDelay);

    if (_currentToken == null) {
      throw Exception('No token to refresh');
    }

    // In a real app, this would call the backend to get a new token
    // For now, just keep the same dummy token
    _currentToken = _dummyToken;
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    // Simulate network delay
    await Future.delayed(_simulatedDelay);

    // Dummy validation
    if (email.isEmpty || password.length < 6 || name.isEmpty) {
      throw Exception('Invalid registration data');
    }

    // In real app, would call backend
    // For now, just return success
    return true;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    // Simulate network delay
    await Future.delayed(_simulatedDelay);

    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    // In real app, would send reset email via backend
    // For now, just simulate the request
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // Simulate network delay
    await Future.delayed(_simulatedDelay);

    if (token.isEmpty || newPassword.length < 6) {
      throw Exception('Invalid reset data');
    }

    // In real app, would call backend to reset password
    // For now, just simulate success
  }
}
