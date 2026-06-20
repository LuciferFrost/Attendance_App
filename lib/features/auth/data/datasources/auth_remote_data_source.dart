import 'package:demo4/core/network/api_client.dart';
import 'package:demo4/features/auth/data/models/auth_user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    if (_client.dio.options.baseUrl.contains('local')) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return const AuthUserModel(
        id: 'EMP-1001',
        email: 'admin@craftedge.local',
        name: 'Anjali Sharma',
        role: 'HR Admin',
      );
    }

    final response = await _client.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthUserModel.fromJson(
      response.data!['user'] as Map<String, dynamic>,
    );
  }
}
