import 'package:flutter/material.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/module_item.dart';
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
  final ApiClient _api = ApiClient();

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
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final modules = _selectedDomain == 'All'
        ? official19Modules
        : official19Modules.where((m) => m.domain == _selectedDomain).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SUVIDHA Console',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'State: ${_api.currentTenantId}  |  ULB: ${_api.currentSubTenantId}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
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
      body: Column(
        children: [
          // Officer Info Banner
          Container(
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
                        '${user?.role ?? "Field Inspector"} • ${_api.currentSubTenantId}',
                        style: const TextStyle(color: AppTheme.secondaryTeal, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '19 Modules',
                    style: TextStyle(
                      color: AppTheme.secondaryTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
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

          // 19 Modules Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
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
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
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
    );
  }
}
