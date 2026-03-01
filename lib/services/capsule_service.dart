import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/capsule_stats.dart';

class CapsuleService {
  final Dio _dio = ApiClient.dio;

  Future<CapsuleStats> getCapsuleStats() async {
    try {
      debugPrint(
        '[CAPSULE] Fetching stats from /api/capsule (with auth cookie)...',
      );

      final response = await _dio.get('/api/capsule');

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
}
