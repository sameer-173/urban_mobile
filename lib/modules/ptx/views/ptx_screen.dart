import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';

class PtxScreen extends StatefulWidget {
  const PtxScreen({super.key});

  @override
  State<PtxScreen> createState() => _PtxScreenState();
}

class _PtxScreenState extends State<PtxScreen> {
  final PropertyService _service = PropertyService();
  final TextEditingController _searchController = TextEditingController();

  DashboardStats? _stats;
  List<PropertySummary> _properties = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Tax (PTX)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // KPI Metric Bar
          if (_stats != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  _buildKpiCard('Total Parcels', '${_stats!.totalParcels}', Icons.map_outlined),
                  const SizedBox(width: 8),
                  _buildKpiCard(
                    'Demand',
                    '₹${(_stats!.totalDemand / 100000).toStringAsFixed(1)}L',
                    Icons.currency_rupee_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildKpiCard(
                    'Collected',
                    '₹${(_stats!.totalCollected / 100000).toStringAsFixed(1)}L',
                    Icons.check_circle_outline,
                    color: AppTheme.statusPaid,
                  ),
                ],
              ),
            ),

          // Search Box & Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onSubmitted: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by ULPIN, PTIN, or Owner...',
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
                        label: Text(filter, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppTheme.primaryNavy)),
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

          // Property Cards List
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
                            const Text('No properties found', style: TextStyle(color: AppTheme.textMuted)),
                            TextButton(onPressed: _loadData, child: const Text('Reset search')),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _properties.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final p = _properties[index];
                          final statusColor = _getStatusColor(p.taxStatus);

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                        child: Text(
                                          p.taxStatus,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p.ownerName,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.address,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Ward: ${p.wardName ?? p.wardNumber ?? "Unassigned"}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.secondaryTeal),
                                      ),
                                      Text(
                                        'Demand: ₹${p.currentDemandAmount.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
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
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: color ?? AppTheme.primaryNavy),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
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
