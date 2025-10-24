import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  // this is hard coded mock data, can be used before the implementation of real API
  static const bool use_mock = true; // Set to false when real API is ready

  final Map<String, Map<String, String>> _mockUsers = {
    'test@example.com': {
      'password': 'password',
      'name': 'Test User',
      'id': '1',
    },
    'admin@example.com': {
      'password': 'admin123',
      'name': 'Admin User',
      'id': '2',
    },
    'staff@example.com': {
      'password': 'staff123',
      'name': 'Staff Member',
      'id': '3',
    },
  };

  @override
  Future<UserModel> login(String email, String password) async {
    // ✅ Use mock authentication if enabled
    if (use_mock) {
      return _mockLogin(email, password);
    }

    // Real API authentication
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(milliseconds: AppConstants.connectionTimeout),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Check if response has the expected structure
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return UserModel.fromJson(jsonResponse['data']);
        } else {
          throw ServerException(
            jsonResponse['message'] ?? 'Login failed',
          );
        }
      } else if (response.statusCode == 401) {
        throw AuthException('Invalid email or password');
      } else if (response.statusCode == 422) {
        final jsonResponse = json.decode(response.body);
        throw AuthException(
          jsonResponse['message'] ?? 'Validation error',
        );
      } else {
        throw ServerException(
          'Server error: ${response.statusCode}',
        );
      }
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Network error: $e');
    }
  }

  // ✅ Mock login implementation
  Future<UserModel> _mockLogin(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if user exists
    if (_mockUsers.containsKey(email)) {
      final userData = _mockUsers[email]!;
      
      // Check password
      if (userData['password'] == password) {
        return UserModel(
          id: userData['id']!,
          email: email,
          name: userData['name']!,
          token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        throw AuthException('Invalid password');
      }
    } else {
      throw AuthException('User not found');
    }
  }

  @override
  Future<void> logout(String token) async {
    // ✅ Use mock logout if enabled
    if (use_mock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    // Real API logout
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.logoutEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(milliseconds: AppConstants.connectionTimeout),
      );

      if (response.statusCode != 200) {
        throw ServerException('Logout failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Network error during logout: $e');
    }
  }
}