import 'package:flutter/material.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/models/module_item.dart';
import '../../../core/models/tenant_model.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/views/login_screen.dart';
import '../../ptx/views/ptx_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _auth = AuthService();
  final TenantService _tenantService = TenantService();

  String _selectedDomain = 'All';

  final List<String> _domains = [
    'All',
    'Revenue & Billing',
    'Citizen & Welfare',
    'Planning & Regulation',
    'Infrastructure & Field Ops',
    'Finance & Admin',
  ];

  @override
  void initState() {
    super.initState();
    _tenantService.fetchTenants().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final modules = _selectedDomain == 'All'
        ? official19Modules
        : official19Modules.where((m) => m.domain == _selectedDomain).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SUVIDHA Console',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Field Officer & Inspector Terminal',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              final nav = Navigator.of(context);
              await _auth.logout();
              if (mounted) {
                nav.pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Officer Info Banner with Interactive Tenant Dropdown
            ValueListenableBuilder<TenantModel>(
              valueListenable: _tenantService.activeTenant,
              builder: (context, activeTenant, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryNavy,
                        child: Text(
                          (user?.name.isNotEmpty ?? false) ? user!.name[0] : 'O',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name.isNotEmpty ?? false ? user!.name : 'Municipal Officer',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '${user?.role ?? "revenue_officer"} • ${activeTenant.name}',
                              style: const TextStyle(color: AppTheme.secondaryTeal, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTenantDropdown(activeTenant),
                    ],
                  ),
                );
              },
            ),

            // Domain Filter Horizontal Bar
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _domains.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final domain = _domains[index];
                  final isSelected = domain == _selectedDomain;
                  return ChoiceChip(
                    label: Text(domain),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryNavy,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryNavy,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedDomain = domain);
                    },
                  );
                },
              ),
            ),

            // 19 Modules Grid with Safe Bottom Padding & Aspect Ratio
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.of(context).padding.bottom + 32,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.86,
                ),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final mod = modules[index];
                  final isPtx = mod.code == 'PTX';

                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (isPtx) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PtxScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${mod.name} (${mod.code}) module coming in Phase next'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isPtx
                                        ? AppTheme.accentSaffron.withValues(alpha: 0.15)
                                        : AppTheme.primaryNavy.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    mod.icon,
                                    color: isPtx ? AppTheme.accentSaffron : AppTheme.primaryNavy,
                                    size: 26,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.borderBeige,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    mod.code,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryNavy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              mod.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mod.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (isPtx)
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, size: 12, color: AppTheme.statusPaid),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ready to Inspect',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.statusPaid,
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

  Widget _buildTenantDropdown(TenantModel activeTenant) {
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      tooltip: 'Select Municipal Corporation',
      onSelected: (String newTenantId) {
        _tenantService.switchTenantById(newTenantId);
        setState(() {});
      },
      itemBuilder: (BuildContext context) {
        return _tenantService.availableTenants.map((t) {
          final isSelected = t.tenantId == activeTenant.tenantId;
          return PopupMenuItem<String>(
            value: t.tenantId,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentSaffron.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_city_rounded,
                    size: 20,
                    color: isSelected ? AppTheme.accentSaffron : AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            t.tenantId,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? AppTheme.accentSaffron : AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${t.totalParcels} Parcels',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            const Spacer(),
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: AppTheme.accentSaffron,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.name,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accentSaffron.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accentSaffron.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_city_rounded, size: 14, color: AppTheme.accentSaffron),
            const SizedBox(width: 4),
            Text(
              activeTenant.tenantId,
              style: const TextStyle(
                color: AppTheme.accentSaffron,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 20,
              color: AppTheme.accentSaffron,
            ),
          ],
        ),
      ),
    );
  }
}
