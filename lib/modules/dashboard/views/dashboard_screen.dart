import 'package:flutter/material.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/models/module_item.dart';
import '../../../core/models/tenant_model.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/tenant_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/views/login_screen.dart';
import '../../ptx/views/ptx_screen.dart';
import '../../../shared/widgets/online_status_beacon.dart';
import 'gis_spatial_view.dart';
import 'pending_tasks_view.dart';
import 'analytics_demands_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _auth = AuthService();
  final TenantService _tenantService = TenantService();
  late final PageController _pageController;

  int _currentTabIndex = 0;
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
    _pageController = PageController(initialPage: _currentTabIndex);
    _tenantService.fetchTenants().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentTabIndex == index) return;
    setState(() => _currentTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Color _getDomainBgColor(String domain) {
    switch (domain) {
      case 'Revenue & Billing':
        return const Color(0xFFC77817).withValues(alpha: 0.12);
      case 'Citizen & Welfare':
        return const Color(0xFFE26D5C).withValues(alpha: 0.12);
      case 'Planning & Regulation':
        return const Color(0xFF4A7C59).withValues(alpha: 0.12);
      case 'Infrastructure & Field Ops':
        return const Color(0xFF1B8C77).withValues(alpha: 0.12);
      case 'Finance & Admin':
        return const Color(0xFF0E3A52).withValues(alpha: 0.12);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getDomainIconColor(String domain) {
    switch (domain) {
      case 'Revenue & Billing':
        return const Color(0xFFC77817);
      case 'Citizen & Welfare':
        return const Color(0xFFD35400);
      case 'Planning & Regulation':
        return const Color(0xFF2E7D32);
      case 'Infrastructure & Field Ops':
        return const Color(0xFF1B8C77);
      case 'Finance & Admin':
        return const Color(0xFF0E3A52);
      default:
        return AppTheme.primaryNavy;
    }
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'PUROJAS';
      case 1:
        return 'Municipal Modules';
      case 2:
        return 'GIS Spatial View';
      case 3:
        return 'Pending Tasks & SLAs';
      case 4:
        return 'Analytics & Demands';
      default:
        return 'PUROJAS';
    }
  }

  String _getTabSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Executive Dashboard & Records';
      case 1:
        return '19 Integrated ERP Workspaces';
      case 2:
        return 'Cadastral Parcels & Boundaries';
      case 3:
        return 'Field Action Queue & Charters';
      case 4:
        return 'Municipal Revenue Performance';
      default:
        return 'Field Officer & Inspector Terminal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final modules = _selectedDomain == 'All'
        ? official19Modules
        : official19Modules.where((m) => m.domain == _selectedDomain).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Column(
            key: ValueKey<int>(_currentTabIndex),
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getTabTitle(_currentTabIndex),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getTabSubtitle(_currentTabIndex),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Classy animated online/offline beacon
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: OnlineStatusBeacon(),
            ),
          ),
          // Tenant quick switcher in AppBar for non-overview/non-modules tabs
          if (_currentTabIndex >= 2)
            ValueListenableBuilder<TenantModel>(
              valueListenable: _tenantService.activeTenant,
              builder: (context, activeTenant, _) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: _buildTenantDropdown(activeTenant),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
        bottom: false,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Keeps pan gestures in Leaflet map clean
          children: [
            // Tab 0: Overview & Records (Executive Municipal Dashboard & Records)
            _KeepAliveWrapper(
              child: _buildOverviewDashboardTab(context, user),
            ),

            // Tab 1: All Modules (19 Municipal modules + domain filters + profile)
            _KeepAliveWrapper(
              child: _buildAllModulesTab(context, user, modules),
            ),

            // Tab 2: GIS Spatial View (Leaflet engine)
            const _KeepAliveWrapper(
              child: GisSpatialView(),
            ),

            // Tab 3: Pending Tasks & SLAs
            const _KeepAliveWrapper(
              child: PendingTasksView(),
            ),

            // Tab 4: Analytics & Demands
            const _KeepAliveWrapper(
              child: AnalyticsDemandsView(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Tab 0: Overview & Records Dashboard View
  Widget _buildOverviewDashboardTab(BuildContext context, UserProfile? user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Officer Greeting & Active Municipal Corporation Banner
          _buildExecutiveGreetingCard(user),

          // 2. High-impact "All 19 Modules" Interactive Quick Portal Banner
          _buildAllModulesLauncherCard(),

          // 3. Municipal Demand & Revenue Realization Card (with visual progress)
          _buildRevenueRealizationCard(),

          // 4. Executive Operational KPI 4-Card Grid
          _buildOperationalKpiGrid(),

          // 5. Quick Field Action & Workflow Launchers
          _buildQuickActionShortcuts(),

          // 6. High-Priority Action Queue / Inspection Alerts
          _buildUrgentActionQueue(),

          // 7. Recent Municipal Records & Audit Trail Activity
          _buildRecentRecordsStream(),
        ],
      ),
    );
  }

  Widget _buildExecutiveGreetingCard(UserProfile? user) {
    return ValueListenableBuilder<TenantModel>(
      valueListenable: _tenantService.activeTenant,
      builder: (context, activeTenant, _) {
        final officerName = (user?.name.isNotEmpty ?? false) ? user!.name : 'Municipal Officer';
        final initial = officerName.isNotEmpty ? officerName[0].toUpperCase() : 'O';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF071532), Color(0xFF0E3A52)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF071532).withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $officerName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${user?.role ?? "revenue_officer"} • Shift Active',
                          style: const TextStyle(
                            color: Color(0xFF68D391),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTenantDropdown(activeTenant),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBannerStatPill('Parcels', '4,250', Icons.home_work_outlined),
                    Container(width: 1, height: 26, color: Colors.white24),
                    _buildBannerStatPill('Units', '5,120', Icons.apartment_rounded),
                    Container(width: 1, height: 26, color: Colors.white24),
                    _buildBannerStatPill('Jurisdiction', '66 Wards', Icons.location_on_outlined),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerStatPill(String title, String val, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              val,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAllModulesLauncherCard() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0E1FD), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006699).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabTapped(1), // Switch smoothly to All Modules tab
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFE1F0FA),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F0FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.grid_view_rounded, color: Color(0xFF006699), size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'All 19 Municipal Modules',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryTeal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '19 Active',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Tap here to view PTX, Water, Trade Licences, Town Planning...',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF006699),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueRealizationCard() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF0F3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Municipal Demand Realization',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Greater Warangal (GWMC) • FY 2025-26',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '76.0% Achieved',
                  style: TextStyle(
                    color: Color(0xFF047857),
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  flex: 76,
                  child: Container(height: 10, color: const Color(0xFF10B981)),
                ),
                Expanded(
                  flex: 24,
                  child: Container(height: 10, color: AppTheme.accentSaffron),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDemandPill('Collected', '₹36,63,200', const Color(0xFF10B981)),
              _buildDemandPill('Outstanding', '₹11,56,800', AppTheme.accentSaffron),
              _buildDemandPill('Target Demand', '₹48,20,000', AppTheme.primaryNavy),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemandPill(String title, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(title, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationalKpiGrid() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operational Indicators',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: "Today's Field Audits",
                  val: '14 Active',
                  subtitle: '8 Completed today',
                  icon: Icons.assignment_turned_in_rounded,
                  color: const Color(0xFF1B8C77),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'GIS Cadastre Match',
                  val: '98.2%',
                  subtitle: '4,173/4,250 verified',
                  icon: Icons.layers_rounded,
                  color: const Color(0xFF006699),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Citizen SLA Queue',
                  val: '3 Urgent',
                  subtitle: '11 within charter SLA',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFD98A2B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'Demand Notices',
                  val: '1,420 Nos',
                  subtitle: 'Cloud mesh verified',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF0E3A52),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String val,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF0F3), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(
                val,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionShortcuts() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workflows & Terminals',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildShortcutPill(
                label: 'GIS Map',
                icon: Icons.map_rounded,
                color: const Color(0xFF1B8C77),
                onTap: () => _onTabTapped(2),
              ),
              const SizedBox(width: 8),
              _buildShortcutPill(
                label: 'SLA Tasks',
                icon: Icons.assignment_rounded,
                color: const Color(0xFFD98A2B),
                onTap: () => _onTabTapped(3),
              ),
              const SizedBox(width: 8),
              _buildShortcutPill(
                label: 'Analytics',
                icon: Icons.analytics_rounded,
                color: const Color(0xFF006699),
                onTap: () => _onTabTapped(4),
              ),
              const SizedBox(width: 8),
              _buildShortcutPill(
                label: 'PTX Tax',
                icon: Icons.home_work_rounded,
                color: const Color(0xFF0E3A52),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PtxScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutPill({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgentActionQueue() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Urgent Field Action Queue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                  color: AppTheme.primaryNavy,
                ),
              ),
              GestureDetector(
                onTap: () => _onTabTapped(3), // Open Pending Tasks tab
                child: const Text(
                  'View All SLAs →',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006699),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildUrgentCard(
            badge: 'BPM • Setback Deviation',
            title: 'Cadastral Re-survey: Survey No. 142/A',
            address: 'H.No 2-4-123, Postal Colony, Subedari West',
            badgeColor: const Color(0xFFEF4444),
            actionLabel: 'Inspect GIS',
            onAction: () => _onTabTapped(2),
          ),
          const SizedBox(height: 8),
          _buildUrgentCard(
            badge: 'WTR • Flow Anomaly',
            title: 'Commercial Volumetric Meter #4021',
            address: 'Nakkalagutta Commercial Complex, Ward 14',
            badgeColor: const Color(0xFFD98A2B),
            actionLabel: 'Verify',
            onAction: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Water & Sewerage Inspection Queue...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildUrgentCard(
            badge: 'TRL • Renewal Due',
            title: 'Commercial Shop Licence #TRL-8820',
            address: 'Balasamudram Market Square, Ward 22',
            badgeColor: const Color(0xFF1B8C77),
            actionLabel: 'Audit',
            onAction: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Trade Licences Inspection Queue...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentCard({
    required String badge,
    required String title,
    required String address,
    required Color badgeColor,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF0F3), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF071532),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: const Size(44, 34),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecordsStream() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Municipal Records & Activity',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEF0F3), width: 1.2),
            ),
            child: Column(
              children: [
                _buildRecordRow(
                  title: 'Spot Assessment Verified',
                  details: 'PTIN-2026-00042 • Ramesh Chandra (₹4,250)',
                  time: '18m ago',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF10B981),
                ),
                const Divider(height: 16, color: Color(0xFFF3F4F6)),
                _buildRecordRow(
                  title: 'Trade Licence Inspection Passed',
                  details: 'Krishna Enterprises • Subedari Ward 12',
                  time: '1h ago',
                  icon: Icons.verified_outlined,
                  iconColor: const Color(0xFF006699),
                ),
                const Divider(height: 16, color: Color(0xFFF3F4F6)),
                _buildRecordRow(
                  title: 'Cadastral Boundary Reconciled',
                  details: 'Survey 142/A • Leaflet Cadastre Sync',
                  time: '2h ago',
                  icon: Icons.layers_outlined,
                  iconColor: AppTheme.accentSaffron,
                ),
                const Divider(height: 16, color: Color(0xFFF3F4F6)),
                _buildRecordRow(
                  title: 'Water Consumption Logged',
                  details: 'Meter Conn #WTR-1029 • 120.4 kL Volumetric',
                  time: '3h ago',
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFF1B8C77),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordRow({
    required String title,
    required String details,
    required String time,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                details,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  /// Tab 1: All Modules View (19 official modules with domain filters & profile)
  Widget _buildAllModulesTab(
    BuildContext context,
    UserProfile? user,
    List<ModuleItem> modules,
  ) {
    return Column(
      children: [
        // Officer Profile Floating Card with Interactive Tenant Dropdown
        ValueListenableBuilder<TenantModel>(
          valueListenable: _tenantService.activeTenant,
          builder: (context, activeTenant, _) {
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEF0F3), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'O',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name.isNotEmpty ?? false ? user!.name : 'Municipal Officer',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: AppTheme.primaryNavy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${user?.role ?? "revenue_officer"} • ${activeTenant.name}',
                          style: const TextStyle(
                            color: AppTheme.secondaryTeal,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
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

        // Domain Filter Capsule Bar
        Container(
          height: 46,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _domains.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final domain = _domains[index];
              final isSelected = domain == _selectedDomain;
              return InkWell(
                onTap: () {
                  if (!isSelected) {
                    setState(() => _selectedDomain = domain);
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryNavy : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryNavy : const Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryNavy.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      domain,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 19 Modules Grid with Smooth Animation
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.035),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: GridView.builder(
              key: ValueKey<String>(_selectedDomain),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 13,
                mainAxisSpacing: 13,
                childAspectRatio: 0.85,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final mod = modules[index];
                final isPtx = mod.code == 'PTX';

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFEEF0F3), width: 1.2),
                  ),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    splashColor: AppTheme.accentSaffron.withValues(alpha: 0.12),
                    highlightColor: Colors.transparent,
                    onTap: () {
                      if (isPtx) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PtxScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${mod.name} (${mod.code}) module coming in next phase'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isPtx
                                      ? const Color(0xFFC77817).withValues(alpha: 0.12)
                                      : _getDomainBgColor(mod.domain),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  mod.icon,
                                  color: isPtx ? const Color(0xFFC77817) : _getDomainIconColor(mod.domain),
                                  size: 22,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  mod.code,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: Color(0xFF4B5563),
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
                              fontWeight: FontWeight.w700,
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
                              color: Color(0xFF6B7280),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (isPtx)
                            Row(
                              children: const [
                                Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF1B8C77)),
                                SizedBox(width: 4),
                                Text(
                                  'Ready to Inspect',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B8C77),
                                  ),
                                ),
                              ],
                            )
                          else
                            const SizedBox(height: 13),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom Navigation Bar styled identically to the requested SUVIDHA Work Queues
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildBottomNavItem(
                index: 0,
                label: 'Overview',
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
              ),
              _buildBottomNavItem(
                index: 1,
                label: 'All Modules',
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
              ),
              _buildBottomNavItem(
                index: 2,
                label: 'GIS View',
                icon: Icons.map_outlined,
                activeIcon: Icons.map_rounded,
              ),
              _buildBottomNavItem(
                index: 3,
                label: 'Tasks & SLAs',
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment_rounded,
              ),
              _buildBottomNavItem(
                index: 4,
                label: 'Analytics',
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _currentTabIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabTapped(index),
          splashColor: const Color(0xFFE1F0FA),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon pill background container with smooth animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 12 : 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE1F0FA) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    scale: isSelected ? 1.06 : 1.0,
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      size: 20,
                      color: isSelected ? const Color(0xFF006699) : const Color(0xFF4B5563),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: 9.2,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF006699) : const Color(0xFF4B5563),
                    letterSpacing: -0.2,
                    fontFamily: 'sans-serif',
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
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
                        ? const Color(0xFFC77817).withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_city_rounded,
                    size: 20,
                    color: isSelected ? const Color(0xFFC77817) : AppTheme.primaryNavy,
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
                              color: isSelected ? const Color(0xFFC77817) : AppTheme.primaryNavy,
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
                              color: Color(0xFFC77817),
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
          color: const Color(0xFFC77817).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC77817).withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_city_rounded, size: 14, color: Color(0xFFC77817)),
            const SizedBox(width: 4),
            Text(
              activeTenant.tenantId,
              style: const TextStyle(
                color: Color(0xFFC77817),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 20,
              color: Color(0xFFC77817),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper to preserve view state, scroll positions, and map instance across PageView transitions
class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
