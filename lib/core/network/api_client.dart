import 'package:demo4/core/config/app_environment.dart';
import 'package:demo4/core/constants/app_constants.dart';
import 'package:demo4/core/network/network_info.dart';
import 'package:demo4/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(AppEnvironment environment, this._secureStorage, this._networkInfo)
    : dio = Dio(
        BaseOptions(
          baseUrl: environment.apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!await _networkInfo.hasConnection) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                message: 'No internet connection',
              ),
            );
          }

          final token = await _secureStorage.read(AppConstants.authTokenKey);
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
  final SecureStorageService _secureStorage;
  final NetworkInfo _networkInfo;
}
