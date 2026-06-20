/// Abstract repository interface for authentication operations.
///
/// This repository handles all authentication-related operations and should be
/// implemented by a concrete data source repository that communicates with
/// the backend or local storage.
abstract class AuthRepository {
  /// Authenticates a user with email and password.
  ///
  /// Returns true if authentication was successful, false otherwise.
  /// Throws an exception if there's an error during the process.
  Future<bool> login(String email, String password);

  /// Logs out the current user.
  ///
  /// Clears authentication tokens and user data.
  /// Throws an exception if there's an error during logout.
  Future<void> logout();

  /// Checks if a user is currently logged in.
  ///
  /// Returns true if there's a valid session/token, false otherwise.
  Future<bool> isLoggedIn();

  /// Gets the current authenticated user information.
  ///
  /// Returns a map containing user data (id, email, name, etc.).
  /// Throws an exception if no user is logged in or data retrieval fails.
  Future<Map<String, dynamic>> getCurrentUser();

  /// Refreshes the authentication token if needed.
  ///
  /// Should be called periodically to maintain session validity.
  /// Throws an exception if token refresh fails.
  Future<void> refreshToken();

  /// Registers a new user account.
  ///
  /// Throws an exception if registration fails.
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  });

  /// Requests a password reset for the given email.
  ///
  /// Throws an exception if the operation fails.
  Future<void> requestPasswordReset(String email);

  /// Resets password with the provided reset token and new password.
  ///
  /// Throws an exception if the operation fails.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
}
