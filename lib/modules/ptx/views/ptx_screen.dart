import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tenant_model.dart';
import '../../../core/services/tenant_service.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';

class PtxScreen extends StatefulWidget {
  const PtxScreen({super.key});

  @override
  State<PtxScreen> createState() => _PtxScreenState();
}

class _PtxScreenState extends State<PtxScreen> {
  final PropertyService _service = PropertyService();
  final TenantService _tenantService = TenantService();
  final TextEditingController _searchController = TextEditingController();

  DashboardStats? _stats;
  List<PropertySummary> _properties = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tenantService.activeTenant.addListener(_onTenantChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tenantService.activeTenant.removeListener(_onTenantChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onTenantChanged() {
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final stats = await _service.getStatsSummary();
    final props = await _service.listProperties(
      query: _searchController.text.trim(),
      taxStatus: _selectedFilter,
    );

    if (mounted) {
      setState(() {
        _stats = stats;
        _properties = props;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String val) {
    _loadData();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return AppTheme.statusPaid;
      case 'DUE':
        return AppTheme.statusDue;
      case 'ARREARS':
        return AppTheme.statusArrears;
      default:
        return AppTheme.textMuted;
    }
  }

  void _showPropertyDetail(PropertySummary prop) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final statusColor = _getStatusColor(prop.taxStatus);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderBeige,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        prop.ulpin,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        prop.taxStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  prop.ownerName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (prop.ptin != null)
                  Text(
                    'PTIN: ${prop.ptin}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.secondaryTeal, fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundCream,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Address', prop.address),
                      _buildDetailRow('Ward', '${prop.wardName ?? ""} (Ward ${prop.wardNumber ?? ""})'),
                      _buildDetailRow('Survey Number', prop.surveyNumber),
                      _buildDetailRow('Building Usage', prop.usageCategory),
                      _buildDetailRow('Current Tax Demand', '₹${prop.currentDemandAmount.toStringAsFixed(0)}', isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Demand notice generated for ${prop.ulpin}')),
                          );
                        },
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('Notice'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('GIS inspection triggered for ${prop.ulpin}')),
                          );
                        },
                        icon: const Icon(Icons.gps_fixed),
                        label: const Text('GIS Survey'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentSaffron,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isBold ? AppTheme.primaryNavy : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<TenantModel?>(
          valueListenable: _tenantService.activeTenant,
          builder: (context, activeTenant, _) {
            final tenantCode = activeTenant?.tenantId ?? "GWMC";
            final tenantName = activeTenant?.name ?? "Greater Warangal";

            // Direct Dropdown menu popping under the title
            return PopupMenuButton<TenantModel>(
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              color: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppTheme.borderBeige),
              ),
              onSelected: (TenantModel tenant) {
                _tenantService.switchTenant(tenant);
              },
              itemBuilder: (context) {
                return _tenantService.availableTenants.map((t) {
                  final isCurrent = t.tenantId == tenantCode;
                  return PopupMenuItem<TenantModel>(
                    value: t,
                    child: Row(
                      children: [
                        Icon(
                          isCurrent ? Icons.check_circle : Icons.location_city_rounded,
                          color: isCurrent ? AppTheme.statusPaid : AppTheme.secondaryTeal,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.tenantId,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isCurrent ? AppTheme.accentSaffron : AppTheme.primaryNavy,
                                ),
                              ),
                              Text(
                                '${t.name} (${t.totalParcels} parcels)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('PTX • $tenantCode', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 22),
                        ],
                      ),
                      Text(tenantName, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // KPI Summary Dashboard
            if (_stats != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildKpiCard(
                          'Parcels',
                          '${_stats!.totalParcels}',
                          Icons.home_work_outlined,
                          color: AppTheme.primaryNavy,
                        ),
                        const SizedBox(width: 8),
                        _buildKpiCard(
                          'Total Demand',
                          '₹${(_stats!.totalDemand / 1000).toStringAsFixed(1)}K',
                          Icons.currency_rupee_rounded,
                          color: AppTheme.accentSaffron,
                        ),
                        const SizedBox(width: 8),
                        _buildKpiCard(
                          'Collected (76%)',
                          '₹${(_stats!.totalCollected / 1000).toStringAsFixed(1)}K',
                          Icons.check_circle_outline,
                          color: AppTheme.statusPaid,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundCream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_city_rounded, size: 14, color: AppTheme.secondaryTeal),
                              const SizedBox(width: 4),
                              Text(
                                '${_stats!.wardCount} Municipal Wards',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondaryTeal),
                              ),
                            ],
                          ),
                          Text(
                            '${_stats!.residentialCount} Residential • ${_stats!.commercialCount} Commercial',
                            style: const TextStyle(fontSize: 11, color: AppTheme.primaryNavy, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Search Bar & Status Chips
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onSubmitted: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search ULPIN, PTIN, or Owner...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _loadData();
                              },
                            )
                          : null,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.borderBeige),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['ALL', 'DUE', 'PAID', 'ARREARS'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : AppTheme.primaryNavy,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryNavy,
                          onSelected: (val) {
                            setState(() => _selectedFilter = filter);
                            _loadData();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppTheme.borderBeige),

            // Live Properties List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _properties.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted),
                              const SizedBox(height: 8),
                              const Text('No property parcels found', style: TextStyle(color: AppTheme.textMuted)),
                              TextButton(onPressed: _loadData, child: const Text('Reset search filter')),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            12,
                            12,
                            12,
                            MediaQuery.of(context).padding.bottom + 24,
                          ),
                          itemCount: _properties.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final p = _properties[index];
                            final statusColor = _getStatusColor(p.taxStatus);

                            return Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showPropertyDetail(p),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Badges
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              p.ulpin,
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryNavy,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  p.taxStatus == 'PAID'
                                                      ? Icons.check_circle
                                                      : p.taxStatus == 'DUE'
                                                          ? Icons.schedule
                                                          : Icons.error_outline,
                                                  size: 12,
                                                  color: statusColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  p.taxStatus,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // Owner & PTIN
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.ownerName,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (p.ptin != null)
                                            Text(
                                              p.ptin!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.secondaryTeal,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Address
                                      Text(
                                        p.address,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                      const SizedBox(height: 10),
                                      // Footer info
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.backgroundCream,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Ward: ${p.wardName ?? p.wardNumber ?? "Unassigned"}',
                                              style: const TextStyle(fontSize: 11, color: AppTheme.secondaryTeal, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            '₹${p.currentDemandAmount.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryNavy,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primaryNavy).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color ?? AppTheme.primaryNavy),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: color ?? AppTheme.primaryNavy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color ?? AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
