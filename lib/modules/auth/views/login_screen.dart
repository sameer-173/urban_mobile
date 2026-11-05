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

  // Tab switch: false = Sign In, true = New User Registration
  bool _isRegistration = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Sign In Controllers
  final TextEditingController _usernameController =
      TextEditingController(text: 'officer@gwmc.gov.in');
  final TextEditingController _passwordController =
      TextEditingController(text: 'Officer@123');

  // Registration Controllers
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regConfirmPasswordController = TextEditingController();

  String _selectedTenant = 'GWMC';
  String _selectedRole = 'Revenue Officer';

  final List<Map<String, String>> _availableTenants = const [
    {'code': 'GWMC', 'name': 'Greater Warangal (GWMC)'},
    {'code': 'GHMC', 'name': 'Greater Hyderabad (GHMC)'},
    {'code': 'KMC', 'name': 'Karimnagar (KMC)'},
    {'code': 'NMC', 'name': 'Nizamabad (NMC)'},
  ];

  final List<String> _roles = const [
    'Revenue Officer',
    'Field Surveyor & GIS Inspector',
    'Town Planning Inspector',
    'Sanitation & Health Inspector',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email/username and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _auth.loginDirect(username, password, tenantId: _selectedTenant);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _navigateToDashboard();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid credentials. Please verify your officer credentials.'),
          backgroundColor: AppTheme.statusArrears,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final pass = _regPasswordController.text.trim();
    final confirmPass = _regConfirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required registration fields')),
      );
      return;
    }

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppTheme.statusArrears,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await _auth.registerOfficer(
      fullName: name,
      email: email,
      tenantId: _selectedTenant,
      designation: _selectedRole,
      password: pass,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Officer account created for $name! You can now sign in.'),
          backgroundColor: AppTheme.statusPaid,
        ),
      );
      // Auto-populate into sign in
      _usernameController.text = email;
      _passwordController.text = pass;
      setState(() => _isRegistration = false);
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
                    width: 68,
                    height: 68,
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
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Main Title
                const Text(
                  'PUROJAS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryNavy,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),

                // Subtitle 1: Teal uppercase
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

                // Subtitle 2: Muted gray
                const Text(
                  'Field Officer & Inspector Terminal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF5A6E7D),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),

                // Main Unified Authentication Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEEF0F3), width: 1.2),
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
                      // Segmented Tab Switcher: [ Sign In ] | [ New User Registration ]
                      _buildSegmentedTabBar(),
                      const SizedBox(height: 22),

                      // Smooth Animated CrossFade with morphing height curves
                      AnimatedCrossFade(
                        firstChild: _buildSignInForm(),
                        secondChild: _buildRegistrationForm(),
                        crossFadeState: _isRegistration
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 320),
                        firstCurve: Curves.easeInOut,
                        secondCurve: Curves.easeInOut,
                        sizeCurve: Curves.easeInOutCubic,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer Security Mesh & Build Version
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shield_outlined, size: 14, color: Color(0xFF80A0AF)),
                    SizedBox(width: 6),
                    Text(
                      'Protected by PUROJAS Multi-Tenant Security Mesh',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Urban Integrated Municipal ERP • Enterprise SaaS Platform',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
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

  /// Segmented Tab Switcher with smooth gliding indicator
  Widget _buildSegmentedTabBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final halfWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              // Gliding Navy Pill Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOutCubic,
                left: _isRegistration ? halfWidth : 0,
                top: 0,
                bottom: 0,
                width: halfWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Labels
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_isRegistration) setState(() => _isRegistration = false);
                      },
                      borderRadius: BorderRadius.circular(10),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: !_isRegistration ? FontWeight.w700 : FontWeight.w600,
                            color: !_isRegistration ? Colors.white : const Color(0xFF6B7280),
                            fontFamily: 'sans-serif',
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (!_isRegistration) setState(() => _isRegistration = true);
                      },
                      borderRadius: BorderRadius.circular(10),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _isRegistration ? FontWeight.w700 : FontWeight.w600,
                            color: _isRegistration ? Colors.white : const Color(0xFF6B7280),
                            fontFamily: 'sans-serif',
                          ),
                          child: const Text('New User Registration'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Sign In Form Layout
  Widget _buildSignInForm() {
    return Column(
      key: const ValueKey<String>('SignInForm'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Official Email or Username Field
        _buildLabeledField(
          label: 'Official Email or Username',
          child: TextField(
            controller: _usernameController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: _buildInputDecoration(
              hint: 'name@domain.gov.in or username',
              icon: Icons.mail_outline_rounded,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Password Field with Eye Toggle
        _buildLabeledField(
          label: 'Password',
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: _buildInputDecoration(
              hint: 'Enter your security credential',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF9CA3AF),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Sign In to Workspace Button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSignIn,
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
                    'Sign In to Workspace',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 18),

        // Quick Role Pre-fill Chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRoleChip(
              label: 'GWMC Officer',
              onTap: () {
                _usernameController.text = 'officer@gwmc.gov.in';
                _passwordController.text = 'Officer@123';
                _selectedTenant = 'GWMC';
              },
            ),
            const SizedBox(width: 10),
            _buildRoleChip(
              label: 'State Director',
              onTap: () {
                _usernameController.text = 'admin@urban.gov.in';
                _passwordController.text = 'Admin@123';
                _selectedTenant = 'GWMC';
              },
            ),
          ],
        ),
      ],
    );
  }

  /// New User Registration Form Layout
  Widget _buildRegistrationForm() {
    return Column(
      key: const ValueKey<String>('RegistrationForm'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full Official Name Field
        _buildLabeledField(
          label: 'Full Name',
          child: TextField(
            controller: _regNameController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: _buildInputDecoration(
              hint: 'e.g. Ramesh Chandra Reddy',
              icon: Icons.person_outline_rounded,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Official Government Email
        _buildLabeledField(
          label: 'Official Email ID',
          child: TextField(
            controller: _regEmailController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration(
              hint: 'officer@gwmc.gov.in',
              icon: Icons.mail_outline_rounded,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Municipal Corporation (ULB) Dropdown
        _buildLabeledField(
          label: 'Municipal Corporation (ULB)',
          child: DropdownButtonFormField<String>(
            initialValue: _selectedTenant,
            decoration: _buildInputDecoration(
              hint: 'Select your ULB',
              icon: Icons.location_city_rounded,
            ),
            items: _availableTenants.map((t) {
              return DropdownMenuItem<String>(
                value: t['code'],
                child: Text(t['name']!, style: const TextStyle(fontSize: 13.5)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedTenant = val);
            },
          ),
        ),
        const SizedBox(height: 14),

        // Official Role / Designation Dropdown
        _buildLabeledField(
          label: 'Officer Designation',
          child: DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            decoration: _buildInputDecoration(
              hint: 'Select designation',
              icon: Icons.badge_outlined,
            ),
            items: _roles.map((r) {
              return DropdownMenuItem<String>(
                value: r,
                child: Text(r, style: const TextStyle(fontSize: 13.5)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedRole = val);
            },
          ),
        ),
        const SizedBox(height: 14),

        // Create Password Field
        _buildLabeledField(
          label: 'Create Password',
          child: TextField(
            controller: _regPasswordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: _buildInputDecoration(
              hint: 'Minimum 8 characters',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF9CA3AF),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Confirm Password Field
        _buildLabeledField(
          label: 'Confirm Password',
          child: TextField(
            controller: _regConfirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            decoration: _buildInputDecoration(
              hint: 'Re-enter your password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF9CA3AF),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Register Button
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryTeal,
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
                    'Register Officer Account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF9CA3AF)),
      prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
      suffixIcon: suffixIcon,
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
    );
  }

  Widget _buildRoleChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_pin_circle_rounded, size: 14, color: AppTheme.secondaryTeal),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
