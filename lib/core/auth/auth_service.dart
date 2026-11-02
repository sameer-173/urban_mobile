import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/user_profile.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiClient _api = ApiClient();

  // Keycloak OIDC Settings
  // On Android emulator, Keycloak on port 8085 is reached via 10.0.2.2:8085
  static const String keycloakIssuer = 'http://10.0.2.2:8085/realms/urban';
  static const String clientId = 'urban-web';
  static const String redirectUrl = 'org.suvidha.urban://oauth2redirect';

  UserProfile? currentUser;

  AuthService._internal();

  /// 1. Keycloak SSO Login via OAuth2 PKCE
  Future<bool> loginWithKeycloak() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: keycloakIssuer,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
        ),
      );

      if (result != null && result.accessToken != null) {
        await _storage.write(key: 'access_token', value: result.accessToken);
        if (result.refreshToken != null) {
          await _storage.write(key: 'refresh_token', value: result.refreshToken);
        }
        
        // Fetch current user details
        await fetchCurrentUser();
        return true;
      }
      return false;
    } catch (e) {
      print('Keycloak SSO error: $e');
      return false;
    }
  }

  /// 2. Direct Municipal Officer Login (Password Credentials Fallback)
  Future<bool> loginDirect(String username, String password, {String tenantId = 'GWMC'}) async {
    try {
      final response = await _api.dio.post(
        '/auth/signin',
        data: {
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
      print('Direct login error: $e');
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
      print('Error fetching user profile: $e');
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
