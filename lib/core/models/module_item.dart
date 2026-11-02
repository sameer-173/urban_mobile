import 'package:flutter/material.dart';

class ModuleItem {
  final String code;
  final String name;
  final String domain;
  final IconData icon;
  final String description;

  const ModuleItem({
    required this.code,
    required this.name,
    required this.domain,
    required this.icon,
    required this.description,
  });
}

// Official 19 Platform Modules
final List<ModuleItem> official19Modules = [
  // 1. Revenue & Billing
  const ModuleItem(
    code: 'PTX',
    name: 'Property Tax',
    domain: 'Revenue & Billing',
    icon: Icons.home_work_rounded,
    description: 'ULPIN property surveys, GIS sync, and tax assessments',
  ),
  const ModuleItem(
    code: 'WTR',
    name: 'Water & Sewerage',
    domain: 'Revenue & Billing',
    icon: Icons.water_drop_rounded,
    description: 'Meter readings, water connections, and volumetric billing',
  ),
  const ModuleItem(
    code: 'TRL',
    name: 'Trade Licences',
    domain: 'Revenue & Billing',
    icon: Icons.storefront_rounded,
    description: 'Commercial inspection, renewals, and trade certs',
  ),
  const ModuleItem(
    code: 'UCH',
    name: 'User Charges',
    domain: 'Revenue & Billing',
    icon: Icons.receipt_long_rounded,
    description: 'Market cess, parking, and community hall charges',
  ),
  const ModuleItem(
    code: 'MPM',
    name: 'Municipal Property',
    domain: 'Revenue & Billing',
    icon: Icons.domain_rounded,
    description: 'Civic lease management and land asset registry',
  ),

  // 2. Citizen Engagement & Welfare
  const ModuleItem(
    code: 'GRV',
    name: 'Grievance & RTI',
    domain: 'Citizen & Welfare',
    icon: Icons.report_problem_rounded,
    description: 'Citizen tickets, SLA timers, and field redressal',
  ),
  const ModuleItem(
    code: 'GSC',
    name: 'Govt Schemes',
    domain: 'Citizen & Welfare',
    icon: Icons.accessibility_new_rounded,
    description: 'Welfare beneficiary surveys and direct benefit verification',
  ),

  // 3. Planning & Regulation
  const ModuleItem(
    code: 'BPM',
    name: 'Building Permissions',
    domain: 'Planning & Regulation',
    icon: Icons.foundation_rounded,
    description: 'Setback inspections, plan approvals, and deviation audits',
  ),
  const ModuleItem(
    code: 'TPL',
    name: 'Town Planning',
    domain: 'Planning & Regulation',
    icon: Icons.map_rounded,
    description: 'Masterplan zoning, change of land use, and layouts',
  ),
  const ModuleItem(
    code: 'FNC',
    name: 'Fire NOC',
    domain: 'Planning & Regulation',
    icon: Icons.local_fire_department_rounded,
    description: 'Fire safety equipment audits and compliance NOCs',
  ),
  const ModuleItem(
    code: 'LGL',
    name: 'Legal Cases',
    domain: 'Planning & Regulation',
    icon: Icons.gavel_rounded,
    description: 'Municipal litigation tracking and court hearing dates',
  ),

  // 4. Infrastructure & Field Operations
  const ModuleItem(
    code: 'SWM',
    name: 'Solid Waste',
    domain: 'Infrastructure & Field Ops',
    icon: Icons.delete_outline_rounded,
    description: 'Dump truck route GPS, transfer stations, and bin sensors',
  ),
  const ModuleItem(
    code: 'ENG',
    name: 'Engineering / e-MB',
    domain: 'Infrastructure & Field Ops',
    icon: Icons.construction_rounded,
    description: 'Electronic measurement book and civil works verification',
  ),
  const ModuleItem(
    code: 'SLM',
    name: 'Street Lights',
    domain: 'Infrastructure & Field Ops',
    icon: Icons.lightbulb_outline_rounded,
    description: 'Pole inventory, fault complaints, and timer switching',
  ),
  const ModuleItem(
    code: 'PRK',
    name: 'Parks & Horticulture',
    domain: 'Infrastructure & Field Ops',
    icon: Icons.park_rounded,
    description: 'Urban tree census, park upkeep, and nursery stocks',
  ),
  const ModuleItem(
    code: 'INV',
    name: 'Inventory & Stores',
    domain: 'Infrastructure & Field Ops',
    icon: Icons.inventory_2_rounded,
    description: 'Central store requisitions and asset dispatches',
  ),

  // 5. Finance & Administration
  const ModuleItem(
    code: 'FIN',
    name: 'Finance & Accounts',
    domain: 'Finance & Admin',
    icon: Icons.account_balance_rounded,
    description: 'Double-entry municipal accounting and budget sanctions',
  ),
  const ModuleItem(
    code: 'HRM',
    name: 'Payroll & HR',
    domain: 'Finance & Admin',
    icon: Icons.badge_rounded,
    description: 'Municipal staff attendance, geo-fencing, and leaves',
  ),
  const ModuleItem(
    code: 'DMS',
    name: 'Document Management',
    domain: 'Finance & Admin',
    icon: Icons.folder_shared_rounded,
    description: 'Secure dossier vault, OCR scanning, and digital signatures',
  ),
];
