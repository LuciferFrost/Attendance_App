import 'package:demo4/core/constants/app_constants.dart';
import 'package:demo4/core/storage/secure_storage_service.dart';
import 'package:demo4/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:demo4/features/auth/data/models/auth_user_model.dart';
import 'package:demo4/features/auth/domain/entities/auth_user.dart';
import 'package:demo4/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final user = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _secureStorage.write(AppConstants.authTokenKey, 'sample-token');
    return user.toEntity();
  }

  @override
  Future<void> logout() => _secureStorage.delete(AppConstants.authTokenKey);
}
