import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/reading_model.dart';
import '../models/tenant_model.dart';

abstract class MeterLocalDataSource {
  Future<void> cacheReadings(List<ReadingModel> readings);
  Future<List<ReadingModel>> getCachedReadings(String meterId);
  Future<void> cacheTenants(List<TenantModel> tenants);
  Future<List<TenantModel>> getCachedTenants();
  Future<void> clearCache();
}

class MeterLocalDataSourceImpl implements MeterLocalDataSource {
  final SharedPreferences sharedPreferences;

  MeterLocalDataSourceImpl({required this.sharedPreferences});

  static const String _readingsKey = 'cached_readings_';
  static const String _tenantsKey = 'cached_tenants';

  @override
  Future<void> cacheReadings(List<ReadingModel> readings) async {
    try {
      if (readings.isEmpty) return;
      
      final meterId = readings.first.meterId;
      final jsonList = readings.map((r) => r.toJson()).toList();
      await sharedPreferences.setString(
        '$_readingsKey$meterId',
        json.encode(jsonList),
      );
    } catch (e) {
      throw CacheException('Failed to cache readings: $e');
    }
  }

  @override
  Future<List<ReadingModel>> getCachedReadings(String meterId) async {
    try {
      final jsonString = sharedPreferences.getString('$_readingsKey$meterId');
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List;
        return jsonList
            .map((json) => ReadingModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheException('Failed to get cached readings: $e');
    }
  }

  @override
  Future<void> cacheTenants(List<TenantModel> tenants) async {
    try {
      final jsonList = tenants.map((t) => t.toJson()).toList();
      await sharedPreferences.setString(
        _tenantsKey,
        json.encode(jsonList),
      );
    } catch (e) {
      throw CacheException('Failed to cache tenants: $e');
    }
  }

  @override
  Future<List<TenantModel>> getCachedTenants() async {
    try {
      final jsonString = sharedPreferences.getString(_tenantsKey);
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List;
        return jsonList
            .map((json) => TenantModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheException('Failed to get cached tenants: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = sharedPreferences.getKeys();
      for (final key in keys) {
        if (key.startsWith(_readingsKey) || key == _tenantsKey) {
          await sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}