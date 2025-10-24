import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(
        AppConstants.userDataKey,
        jsonString,
      );
      
      // Also cache the token separately for easy access
      if (user.token != null) {
        await sharedPreferences.setString(
          AppConstants.authTokenKey,
          user.token!,
        );
      }
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(AppConstants.userDataKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(AppConstants.userDataKey);
      await sharedPreferences.remove(AppConstants.authTokenKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = sharedPreferences.getString(AppConstants.authTokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}