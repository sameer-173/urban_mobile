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
  final TextEditingController _passwordController = TextEditingController(text: 'Officer@123');
  bool _isLoading = false;
  bool _showDirectLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleKeycloakSso() async {
    setState(() => _isLoading = true);
    final username = _usernameController.text.trim().isNotEmpty
        ? _usernameController.text.trim()
        : 'officer@gwmc.gov.in';
    final password = _passwordController.text.trim().isNotEmpty
        ? _passwordController.text.trim()
        : 'Officer@123';

    final success = await _auth.loginWithKeycloak(
      username: username,
      password: password,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _navigateToDashboard();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keycloak SSO connection failed. Please check credentials or use Direct Login.'),
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
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _navigateToDashboard();
    } else {
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Emblem Logo
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryNavy.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Main Title
                const Text(
                  'SUVIDHA Mobile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryNavy,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle Line 1: Green/Teal uppercase
                const Text(
                  'URBAN INTEGRATED MUNICIPAL ERP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondaryTeal,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 3),

                // Subtitle Line 2: Muted gray
                const Text(
                  'Field Officer & Inspector Terminal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5A6E7D),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),

                // Primary Action: Saffron Keycloak SSO Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleKeycloakSso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC77817),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.vpn_key_rounded, size: 20, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Sign in with Keycloak SSO',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Secondary Toggle Button: Municipal Password Login
                InkWell(
                  onTap: () {
                    setState(() => _showDirectLogin = !_showDirectLogin);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showDirectLogin ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppTheme.primaryNavy,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Municipal Password Login',
                          style: TextStyle(
                            color: AppTheme.primaryNavy,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Expandable Form Card
                if (_showDirectLogin) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEEF0F3), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        TextField(
                          controller: _usernameController,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                          decoration: InputDecoration(
                            labelText: 'Official Government Email',
                            labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 20,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFDCE2E8)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFDCE2E8)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field with Eye Toggle
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFDCE2E8)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFDCE2E8)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Direct Sign In Button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleDirectLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Sign In Directly',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Quick Role Chips Centered
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildRoleChip(
                              label: 'GWMC Officer',
                              onTap: () {
                                _usernameController.text = 'officer@gwmc.gov.in';
                                _passwordController.text = 'Officer@123';
                              },
                            ),
                            const SizedBox(width: 10),
                            _buildRoleChip(
                              label: 'State Director',
                              onTap: () {
                                _usernameController.text = 'admin@urban.gov.in';
                                _passwordController.text = 'Admin@123';
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Footer Security Mesh & Build Version
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shield_outlined, size: 14, color: Color(0xFF80A0AF)),
                    SizedBox(width: 6),
                    Text(
                      'Protected by SUVIDHA Multi-Tenant Security Mesh',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'v1.0.0 (Build 101)',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
}
