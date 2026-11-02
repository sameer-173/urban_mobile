class DashboardStats {
  final int totalParcels;
  final int totalUnits;
  final double totalDemand;
  final double totalCollected;
  final int residentialCount;
  final int commercialCount;
  final int wardCount;

  DashboardStats({
    required this.totalParcels,
    required this.totalUnits,
    required this.totalDemand,
    required this.totalCollected,
    required this.residentialCount,
    required this.commercialCount,
    required this.wardCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalParcels: json['totalParcels'] ?? 0,
      totalUnits: json['totalUnits'] ?? 0,
      totalDemand: (json['totalDemand'] as num?)?.toDouble() ?? 0.0,
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0.0,
      residentialCount: json['residentialCount'] ?? 0,
      commercialCount: json['commercialCount'] ?? 0,
      wardCount: json['wardCount'] ?? 0,
    );
  }
}

class PropertySummary {
  final String id;
  final String ulpin;
  final String surveyNumber;
  final String address;
  final int? wardNumber;
  final String? wardName;
  final String? buildingType;
  final int totalUnits;
  final String? ptin;
  final String ownerName;
  final String usageCategory;
  final double currentDemandAmount;
  final String taxStatus; // PAID, DUE, ARREARS

  PropertySummary({
    required this.id,
    required this.ulpin,
    required this.surveyNumber,
    required this.address,
    this.wardNumber,
    this.wardName,
    this.buildingType,
    required this.totalUnits,
    this.ptin,
    required this.ownerName,
    required this.usageCategory,
    required this.currentDemandAmount,
    required this.taxStatus,
  });

  factory PropertySummary.fromJson(Map<String, dynamic> json) {
    return PropertySummary(
      id: json['id'] ?? '',
      ulpin: json['ulpin'] ?? '',
      surveyNumber: json['surveyNumber'] ?? '',
      address: json['address'] ?? '',
      wardNumber: json['wardNumber'],
      wardName: json['wardName'],
      buildingType: json['buildingType'],
      totalUnits: json['totalUnits'] ?? 1,
      ptin: json['ptin'],
      ownerName: json['ownerName'] ?? 'Unassigned',
      usageCategory: json['usageCategory'] ?? 'Residential',
      currentDemandAmount: (json['currentDemandAmount'] as num?)?.toDouble() ?? 0.0,
      taxStatus: json['taxStatus'] ?? 'DUE',
    );
  }
}
