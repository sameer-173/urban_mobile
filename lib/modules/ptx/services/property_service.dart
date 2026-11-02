import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../models/property_model.dart';

class PropertyService {
  final ApiClient _api = ApiClient();

  Future<DashboardStats?> getStatsSummary() async {
    try {
      final response = await _api.dio.get('/properties/stats/summary');
      if (response.statusCode == 200 && response.data != null) {
        return DashboardStats.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching PTX stats: $e');
    }
    return null;
  }

  Future<List<PropertySummary>> listProperties({
    String? query,
    String? wardId,
    String? taxStatus,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (wardId != null && wardId.isNotEmpty) queryParams['wardId'] = wardId;
      if (taxStatus != null && taxStatus != 'ALL') queryParams['taxStatus'] = taxStatus;

      final response = await _api.dio.get(
        '/properties',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => PropertySummary.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error listing properties: $e');
    }
    return [];
  }
}

