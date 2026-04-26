import 'package:http/http.dart' as http;
import 'package:nurtur_app_wppl_agile/core/network/api_config.dart';
import 'package:nurtur_app_wppl_agile/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:nurtur_app_wppl_agile/features/auth/data/repositories/remote_auth_repository.dart';
import 'package:nurtur_app_wppl_agile/features/auth/data/services/mock_auth_service.dart';
import 'package:nurtur_app_wppl_agile/features/auth/data/services/remote_auth_service.dart';
import 'package:nurtur_app_wppl_agile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryFactory {
  AuthRepositoryFactory._();

  static final http.Client _httpClient = http.Client();

  static AuthRepository create() {
    if (ApiConfig.isConfigured) {
      return RemoteAuthRepository(
        service: RemoteAuthService(
          client: _httpClient,
          config: ApiConfig.current,
        ),
      );
    }

    return MockAuthRepository(service: const MockAuthService());
  }
}
