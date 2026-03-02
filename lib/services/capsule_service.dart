import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/capsule_stats.dart';

class CapsuleService {
  final Dio _dio = ApiClient.dio;

  Future<CapsuleStats> getCapsuleStats({int? month, int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      debugPrint(
        '[CAPSULE] Fetching stats from /api/capsule (month=$month, year=$year)...',
      );

      final response = await _dio.get(
        '/api/capsule',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      debugPrint('[CAPSULE] Response status: ${response.statusCode}');
      debugPrint('[CAPSULE] Response data: ${response.data}');

      return CapsuleStats.fromJson(response.data);
    } catch (e) {
      debugPrint('[CAPSULE] Error fetching stats: $e');
      if (e is DioException) {
        debugPrint('[CAPSULE] DioError response: ${e.response?.data}');
      }
      return CapsuleStats.empty();
    }
  }

  Future<List<CapsuleMonth>> getAvailableMonths() async {
    try {
      debugPrint(
        '[CAPSULE] Fetching available months from /api/capsule/available...',
      );
      final response = await _dio.get('/api/capsule/available');

      if (response.data is! List) return const [];

      final List<dynamic> rows = response.data as List<dynamic>;
      return rows
          .whereType<Map<String, dynamic>>()
          .map(CapsuleMonth.fromJson)
          .toList();
    } catch (e) {
      debugPrint('[CAPSULE] Error fetching available months: $e');
      return const [];
    }
  }
}
