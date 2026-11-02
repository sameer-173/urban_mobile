class TenantModel {
  final String tenantId;
  final String name;
  final String stateCode;
  final String district;
  final int totalParcels;
  final int totalWards;

  TenantModel({
    required this.tenantId,
    required this.name,
    required this.stateCode,
    required this.district,
    required this.totalParcels,
    required this.totalWards,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      tenantId: json['tenantId'] ?? '',
      name: json['name'] ?? '',
      stateCode: json['stateCode'] ?? 'TG',
      district: json['district'] ?? '',
      totalParcels: json['totalParcels'] ?? 0,
      totalWards: json['totalWards'] ?? 0,
    );
  }
}
