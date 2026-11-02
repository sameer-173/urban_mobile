import 'package:flutter/material.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/views/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _usernameController = TextEditingController(text: 'officer@gwmc.gov.in');
  final TextEditingController _passwordController = TextEditingController(text: 'urban@123');
  bool _isLoading = false;
  bool _showDirectLogin = false;

  Future<void> _handleKeycloakSso() async {
    setState(() => _isLoading = true);
    final success = await _auth.loginWithKeycloak();
    setState(() => _isLoading = false);

    if (success && mounted) {
      _navigateToDashboard();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keycloak SSO canceled or could not reach server. Try Direct Login.'),
          backgroundColor: AppTheme.statusDue,
        ),
      );
    }
  }

  Future<void> _handleDirectLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _auth.loginDirect(username, password);
    setState(() => _isLoading = false);

    if (success && mounted) {
      _navigateToDashboard();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid municipal officer credentials. Please check password.'),
          backgroundColor: AppTheme.statusArrears,
        ),
      );
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Emblem / Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SUVIDHA Mobile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Urban Integrated Municipal ERP\nField Officer & Inspector Terminal',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryTeal,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 36),

                // Primary Action: Keycloak SSO
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleKeycloakSso,
                  icon: const Icon(Icons.vpn_key_rounded, color: Colors.white),
                  label: const Text('Sign in with Keycloak SSO'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentSaffron,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle Direct Municipal Login
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _showDirectLogin = !_showDirectLogin);
                  },
                  icon: Icon(
                    _showDirectLogin ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppTheme.primaryNavy,
                  ),
                  label: Text(
                    _showDirectLogin ? 'Hide Municipal Password Login' : 'Municipal Officer Password Login',
                    style: const TextStyle(color: AppTheme.primaryNavy),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.borderBeige, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),

                if (_showDirectLogin) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.Border.all(color: AppTheme.borderBeige),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Official Government Email',
                            hintText: 'e.g. officer@gwmc.gov.in',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleDirectLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Sign In Directly'),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            ActionChip(
                              label: const Text('GWMC Officer', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _usernameController.text = 'officer@gwmc.gov.in';
                                _passwordController.text = 'urban@123';
                              },
                            ),
                            ActionChip(
                              label: const Text('State Director', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _usernameController.text = 'dir-ma@telangana.gov.in';
                                _passwordController.text = 'urban@123';
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 36),
                const Center(
                  child: Text(
                    'Protected by SUVIDHA Multi-Tenant Security Mesh\nv1.0.0 (Build 101)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
