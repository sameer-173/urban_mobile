import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/theme/app_theme.dart';

class OnlineStatusBeacon extends StatefulWidget {
  final bool showLabel;
  const OnlineStatusBeacon({this.showLabel = true, super.key});

  @override
  State<OnlineStatusBeacon> createState() => _OnlineStatusBeaconState();
}

class _OnlineStatusBeaconState extends State<OnlineStatusBeacon>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivity = ConnectivityService();
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 2.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.75, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showConnectivitySheet(BuildContext context, bool isOnline) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        final lastChecked = _connectivity.lastChecked.value;
        final timeStr =
            '${lastChecked.hour.toString().padLeft(2, '0')}:${lastChecked.minute.toString().padLeft(2, '0')}:${lastChecked.second.toString().padLeft(2, '0')}';

        final activeColor = isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isOnline ? 'Network Online' : 'Network Offline',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: activeColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Ping: $timeStr',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEEF0F3)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Cloud Mesh Sync',
                        isOnline ? 'Active (WebSocket / HTTPS)' : 'Paused (Queued in SQLite)',
                        color: isOnline ? const Color(0xFF10B981) : AppTheme.accentSaffron,
                      ),
                      _buildInfoRow('Field Inspection Mode', isOnline ? 'Live Geotagging' : 'Offline GPS Buffer'),
                      _buildInfoRow('Security Token', 'Encrypted JWT Bearer Valid'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _connectivity.toggleSimulatedOffline();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(
                                _connectivity.isSimulatedOffline
                                    ? 'Simulated Offline mode enabled'
                                    : 'Live connectivity detection restored',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          _connectivity.isSimulatedOffline
                              ? Icons.wifi_rounded
                              : Icons.wifi_off_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _connectivity.isSimulatedOffline ? 'Resume Live' : 'Test Offline',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final ok = await _connectivity.checkConnection();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                backgroundColor: ok ? AppTheme.statusPaid : AppTheme.statusArrears,
                                content: Text(ok ? 'Network ping successful: Online' : 'Network ping failed: Offline'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Re-check'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _connectivity.isOnline,
      builder: (context, isOnline, _) {
        final activeColor = isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444);

        return Tooltip(
          message: isOnline ? 'Device Online (Tap for details)' : 'Device Offline (Tap for details)',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showConnectivitySheet(context, isOnline),
              borderRadius: BorderRadius.circular(20),
              splashColor: activeColor.withValues(alpha: 0.2),
              highlightColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.showLabel ? 9 : 7,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Classy Animated Pulsing Beacon Dot
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Expanding & fading radar pulse ring
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: activeColor.withValues(alpha: 0.9),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Inner glowing solid beacon dot
                          Container(
                            width: 7.5,
                            height: 7.5,
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.65),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (widget.showLabel) ...[
                      const SizedBox(width: 5),
                      Text(
                        isOnline ? 'ONLINE' : 'OFFLINE',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
