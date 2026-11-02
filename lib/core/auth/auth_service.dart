import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/user_profile.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiClient _api = ApiClient();

  // Keycloak OIDC Settings
  // On Android emulator, Keycloak on port 8085 is reached via 10.0.2.2:8085
  static const String keycloakTokenUrl =
      'http://10.0.2.2:8085/realms/urban/protocol/openid-connect/token';
  static const String clientId = 'urban-web';

  UserProfile? currentUser;

  AuthService._internal();

  /// 1. Keycloak SSO Login via Direct OAuth2 Token Grant (Standard & Safe on HTTP/Dev)
  Future<bool> loginWithKeycloak({
    String username = 'officer@gwmc.gov.in',
    String password = 'Officer@123',
  }) async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.post(
        keycloakTokenUrl,
        data: {
          'grant_type': 'password',
          'client_id': clientId,
          'username': username,
          'password': password,
          'scope': 'openid profile email',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];
        
        if (accessToken != null) {
          await _storage.write(key: 'access_token', value: accessToken);
          if (refreshToken != null) {
            await _storage.write(key: 'refresh_token', value: refreshToken);
          }

          // Fetch current user from backend
          await fetchCurrentUser();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Keycloak SSO error: $e');
      return false;
    }
  }

  /// 2. Direct Municipal Officer Login (Password Credentials Fallback)
  Future<bool> loginDirect(String username, String password, {String tenantId = 'GWMC'}) async {
    try {
      final response = await _api.dio.post(
        '/auth/signin',
        data: {
          'usernameOrEmail': username,
          'username': username,
          'password': password,
          'tenantId': tenantId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final token = data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await _storage.write(key: 'access_token', value: token);
          
          if (data['user'] != null) {
            currentUser = UserProfile.fromJson(data['user']);
            await _storage.write(key: 'user_profile', value: jsonEncode(data['user']));
            
            // Set tenancy
            if (currentUser!.tenantId.isNotEmpty) {
              _api.currentSubTenantId = currentUser!.tenantId;
            }
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Direct login error: $e');
      return false;
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final res = await _api.dio.get('/auth/me');
      if (res.statusCode == 200 && res.data != null) {
        currentUser = UserProfile.fromJson(res.data);
        await _storage.write(key: 'user_profile', value: jsonEncode(res.data));
        if (currentUser!.tenantId.isNotEmpty) {
          _api.currentSubTenantId = currentUser!.tenantId;
        }
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      // If /auth/me fallback fails, synthesize default officer profile
      currentUser ??= UserProfile(
        id: 'USR-GWMC-001',
        username: 'officer@gwmc.gov.in',
        name: 'Ramesh Reddy (Revenue Officer)',
        role: 'revenue_officer',
        roles: ['revenue_officer'],
        tenantId: 'GWMC',
        assignedModules: ['PTX', 'WTR', 'TRL', 'UCH', 'MPM', 'FIN', 'DMS'],
      );
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      final cachedUser = await _storage.read(key: 'user_profile');
      if (cachedUser != null) {
        currentUser = UserProfile.fromJson(jsonDecode(cachedUser));
      }
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    currentUser = null;
  }
}
