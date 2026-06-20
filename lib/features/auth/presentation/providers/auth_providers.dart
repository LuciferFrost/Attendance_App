import 'package:demo4/core/di/service_locator.dart';
import 'package:demo4/features/auth/domain/entities/auth_user.dart';
import 'package:demo4/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => sl());

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, AuthUser?>(LoginController.new);

class LoginController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async => null;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .login(email: email, password: password),
    );
  }
}
