import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/tenant_service.dart';

class TaskItem {
  final String id;
  final String moduleCode;
  final String title;
  final String entityRef;
  final String wardInfo;
  final String slaText;
  final bool isUrgent;
  final String priority;
  final String category;
  final double slaProgress; // 0.0 to 1.0 (1.0 = expired)

  const TaskItem({
    required this.id,
    required this.moduleCode,
    required this.title,
    required this.entityRef,
    required this.wardInfo,
    required this.slaText,
    required this.isUrgent,
    required this.priority,
    required this.category,
    required this.slaProgress,
  });
}

class PendingTasksView extends StatefulWidget {
  const PendingTasksView({super.key});

  @override
  State<PendingTasksView> createState() => _PendingTasksViewState();
}

class _PendingTasksViewState extends State<PendingTasksView> {
  final TenantService _tenantService = TenantService();
  String _selectedFilter = 'All';

  final List<TaskItem> _tasks = const [
    TaskItem(
      id: 'TSK-2026-0891',
      moduleCode: 'PTX-P03',
      title: 'GIS Cadastral Reconciliation & Boundary Verification',
      entityRef: 'ULPIN: TG-GWMC-506001-00123',
      wardInfo: 'Ward 12 • Subedari West',
      slaText: 'Due in 3h 45m',
      isUrgent: true,
      priority: 'CRITICAL',
      category: 'Surveys',
      slaProgress: 0.88,
    ),
    TaskItem(
      id: 'TSK-2026-0892',
      moduleCode: 'TRL-P01',
      title: 'Commercial On-Site Trade Audit (Trade License)',
      entityRef: 'License: TRL-GWMC-2026-441 (Suresh Electronics)',
      wardInfo: 'Ward 14 • Nakkalagutta Commercial',
      slaText: 'Due in 7h 15m',
      isUrgent: true,
      priority: 'HIGH',
      category: 'Trade',
      slaProgress: 0.72,
    ),
    TaskItem(
      id: 'TSK-2026-0893',
      moduleCode: 'PTX-P05',
      title: 'New Assessment Field Survey (Built 2-Storey House)',
      entityRef: 'PTIN: PTIN-GWMC-2026-00042',
      wardInfo: 'Ward 8 • KU Cross Roads',
      slaText: 'Due in 22h',
      isUrgent: false,
      priority: 'MEDIUM',
      category: 'Surveys',
      slaProgress: 0.45,
    ),
    TaskItem(
      id: 'TSK-2026-0894',
      moduleCode: 'GRV-P04',
      title: 'Citizen Road Defect Spot Inspection & Photo Verification',
      entityRef: 'Grievance: GRV-2026-0918 (Pothole & Drainage)',
      wardInfo: 'Ward 5 • Balasamudram Central',
      slaText: 'Due in 1d 4h',
      isUrgent: false,
      priority: 'NORMAL',
      category: 'Grievance',
      slaProgress: 0.35,
    ),
    TaskItem(
      id: 'TSK-2026-0895',
      moduleCode: 'WTR-P02',
      title: 'Water Meter Discrepancy & Unmetered Borewell Audit',
      entityRef: 'Connection: WTR-GWMC-88124',
      wardInfo: 'Ward 22 • Industrial Zone East',
      slaText: 'Due in 2d 10h',
      isUrgent: false,
      priority: 'NORMAL',
      category: 'Water',
      slaProgress: 0.20,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeTenant = _tenantService.activeTenant.value;

    final filteredTasks = _selectedFilter == 'All'
        ? _tasks
        : _selectedFilter == 'Critical SLA'
            ? _tasks.where((t) => t.isUrgent).toList()
            : _tasks.where((t) => t.category == _selectedFilter).toList();

    return Column(
      children: [
        // SLA Overview Metrics Banner
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Officer Action Queue • ${activeTenant.tenantId}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Telangana Municipal SLAs (TS-bPASS / Citizen Charter)',
                          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.statusArrears.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.statusArrears.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.timer_outlined, size: 13, color: AppTheme.statusArrears),
                        SizedBox(width: 4),
                        Text(
                          '2 At Risk',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.statusArrears,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricPill('Pending', '${_tasks.length}', AppTheme.primaryNavy),
                  const SizedBox(width: 6),
                  _buildMetricPill('Critical (<24h)', '2', AppTheme.statusArrears),
                  const SizedBox(width: 6),
                  _buildMetricPill('In Progress', '3', AppTheme.accentSaffron),
                  const SizedBox(width: 6),
                  _buildMetricPill('Done Today', '5', AppTheme.statusPaid),
                ],
              ),
            ],
          ),
        ),

        // Filter Pills Bar
        Container(
          height: 42,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('All'),
              _buildFilterChip('Critical SLA'),
              _buildFilterChip('Surveys'),
              _buildFilterChip('Trade'),
              _buildFilterChip('Grievance'),
            ],
          ),
        ),

        // Tasks List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
            itemCount: filteredTasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return _buildTaskCard(task);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricPill(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final isUrgentChip = label == 'Critical SLA';

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: isUrgentChip
            ? const Icon(Icons.error_outline_rounded, size: 14, color: AppTheme.statusArrears)
            : null,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : isUrgentChip
                  ? AppTheme.statusArrears
                  : const Color(0xFF374151),
        ),
        selected: isSelected,
        selectedColor: isUrgentChip ? AppTheme.statusArrears : AppTheme.primaryNavy,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected
              ? (isUrgentChip ? AppTheme.statusArrears : AppTheme.primaryNavy)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
        onSelected: (_) {
          setState(() => _selectedFilter = label);
        },
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: task.isUrgent
              ? AppTheme.statusArrears.withValues(alpha: 0.4)
              : const Color(0xFFE5E7EB),
          width: task.isUrgent ? 1.4 : 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Module & SLA Countdown Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.moduleCode,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.isUrgent
                            ? AppTheme.statusArrears.withValues(alpha: 0.1)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.priority,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: task.isUrgent ? AppTheme.statusArrears : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isUrgent
                        ? AppTheme.statusArrears.withValues(alpha: 0.12)
                        : AppTheme.accentSaffron.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: task.isUrgent ? AppTheme.statusArrears : AppTheme.accentSaffron,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.slaText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: task.isUrgent ? AppTheme.statusArrears : const Color(0xFF9E6300),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Task Title
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),

            // Entity Reference & Location
            Text(
              task.entityRef,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryTeal,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 13, color: Color(0xFF6B7280)),
                const SizedBox(width: 3),
                Text(
                  task.wardInfo,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SLA Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: task.slaProgress,
                minHeight: 5,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(
                  task.isUrgent ? AppTheme.statusArrears : AppTheme.accentSaffron,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showTaskDetails(task);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Dossier', style: TextStyle(fontSize: 12.5)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.secondaryTeal,
                          content: Text('Field Audit initiated for ${task.id}'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isUrgent ? AppTheme.accentSaffron : AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Start Inspection', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(TaskItem task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  task.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Task ID: ${task.id}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                Text('Target: ${task.entityRef}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('Location: ${task.wardInfo}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                Text('SLA Status: ${task.slaText}', style: const TextStyle(fontSize: 13, color: AppTheme.statusArrears, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Task ${task.id} assigned to field kit')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text('Accept & Begin Audit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
