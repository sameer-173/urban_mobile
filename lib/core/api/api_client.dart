import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  // 10.0.2.2 points to host machine on Android emulator
  // When testing on physical device via adb reverse, localhost:8000 works.
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  
  late final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Active Multi-Tenant Context
  String currentTenantId = 'TG';      // State Level
  String currentSubTenantId = 'GWMC'; // City/ULB Level

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // SUVIDHA Multi-Tenancy Invariant Headers
        options.headers['X-Tenant-ID'] = currentTenantId;
        options.headers['X-Sub-Tenant-ID'] = currentSubTenantId;
        
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Can handle auto-refresh token or offline cache fallback here
        return handler.next(error);
      },
    ));
  }
}
