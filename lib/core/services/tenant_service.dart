import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/tenant_model.dart';

class TenantService {
  static final TenantService _instance = TenantService._internal();
  factory TenantService() => _instance;

  final ApiClient _api = ApiClient();

  // Baseline registered municipal corporations (ensures dropdown is never empty)
  List<TenantModel> availableTenants = [
    TenantModel(
      tenantId: 'GWMC',
      name: 'Greater Warangal Municipal Corporation',
      stateCode: 'TG',
      district: 'Hanamkonda & Warangal',
      totalParcels: 5,
      totalWards: 5,
    ),
    TenantModel(
      tenantId: 'GHMC',
      name: 'Greater Hyderabad Municipal Corporation',
      stateCode: 'TG',
      district: 'Hyderabad',
      totalParcels: 2,
      totalWards: 3,
    ),
  ];

  late final ValueNotifier<TenantModel> activeTenant =
      ValueNotifier<TenantModel>(availableTenants.first);

  TenantService._internal() {
    fetchTenants();
  }

  Future<List<TenantModel>> fetchTenants() async {
    try {
      final response = await _api.dio.get('/tenants');
      if (response.statusCode == 200 && response.data is List) {
        final fetched = (response.data as List)
            .map((item) => TenantModel.fromJson(item))
            .toList();

        if (fetched.isNotEmpty) {
          availableTenants = fetched;
          // Sync active tenant
          final matched = availableTenants.firstWhere(
            (t) => t.tenantId == _api.currentSubTenantId,
            orElse: () => availableTenants.first,
          );
          switchTenant(matched);
        }
      }
    } catch (e) {
      debugPrint('Error fetching tenants: $e');
    }
    return availableTenants;
  }

  void switchTenantById(String tenantId) {
    final tenant = availableTenants.firstWhere(
      (t) => t.tenantId == tenantId,
      orElse: () => availableTenants.first,
    );
    switchTenant(tenant);
  }

  void switchTenant(TenantModel tenant) {
    activeTenant.value = tenant;
    _api.currentSubTenantId = tenant.tenantId;
    _api.currentTenantId = tenant.stateCode;
  }
}
