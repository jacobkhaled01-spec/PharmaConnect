import 'package:flutter/material.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRegistering = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'يرجى إدخال البريد الإلكتروني وكلمة المرور';
      });
      return;
    }

    AuthResult result;
    if (_isRegistering) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      if (name.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'يرجى إدخال اسمك الكامل';
        });
        return;
      }
      result = await ApiService().register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
    } else {
      result = await ApiService().login(email, password);
    }

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isRegistering ? 'تم إنشاء الحساب بنجاح!' : 'تم تسجيل الدخول بنجاح!'),
            backgroundColor: PharmaTheme.primaryGreen,
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = result.errorMessage ?? 'تعذر المصادقة. يرجى التحقق من البيانات المدخلة.';
      });
    }
  }

  void _logout() {
    ApiService().logout();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService().currentUser;
    final isLoggedIn = ApiService().isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي والحساب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: isLoggedIn && user != null ? _buildProfileView(user) : _buildAuthForm(),
      ),
    );
  }

  Widget _buildProfileView(dynamic user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? PharmaTheme.darkSurface : Colors.white;
    final borderColor = isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0);

    return Column(
      children: [
        // بطاقة الهوية الشخصية
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 8),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : PharmaTheme.mintAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: isDark ? const Color(0xFF6EE7B7) : PharmaTheme.primaryGreenDark,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted,
                ),
              ),
              if (user.phone != null) ...[
                const SizedBox(height: 4),
                Text(
                  user.phone!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B).withAlpha(120) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'مريض مسجل ومعتمد',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // إعدادات وبيانات إضافية
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              // تبديل المظهر الليلي / النهاري
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : PharmaTheme.mintAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? const Color(0xFF34D399) : PharmaTheme.primaryGreenDark,
                    size: 20,
                  ),
                ),
                title: const Text('المظهر الليلي (Dark Mode)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(
                  isDark ? 'مفعل (ثيم مريح للعينين في الإضاءة الخافتة)' : 'معطل (الثيم النهاري الطبي)',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                trailing: Switch(
                  value: ThemeController().isDarkMode,
                  activeThumbColor: PharmaTheme.primaryGreen,
                  activeTrackColor: PharmaTheme.mintAccent,
                  onChanged: (val) {
                    ThemeController().toggleTheme();
                    setState(() {});
                  },
                ),
              ),
              Divider(height: 16, color: borderColor),
              _buildSettingTile(Icons.location_city_outlined, 'المدينة والنطاق الجغرافي', 'صنعاء، اليمن'),
              Divider(height: 16, color: borderColor),
              _buildSettingTile(Icons.timer_outlined, 'مدة صلاحية الحجز الافتراضية', '30 دقيقة (TTL)'),
              Divider(height: 16, color: borderColor),
              _buildSettingTile(Icons.notifications_active_outlined, 'إشعارات توفر الدواء', 'مفعلة تلقائياً'),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // زر تسجيل الخروج
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2),
            foregroundColor: isDark ? const Color(0xFFFCA5A5) : PharmaTheme.statusDanger,
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            side: BorderSide(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA)),
          ),
          onPressed: _logout,
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('تسجيل الخروج من الحساب', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? PharmaTheme.darkSurface : Colors.white;
    final borderColor = isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : PharmaTheme.mintAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: isDark ? const Color(0xFF6EE7B7) : PharmaTheme.primaryGreenDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRegistering ? 'إنشاء حساب مريض جديد' : 'تسجيل دخول المريض',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'لحفظ ومتابعة حجوزاتك الدوائية بسهولة',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: PharmaTheme.statusDanger, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: PharmaTheme.statusDanger, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_isRegistering) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل',
                hintText: 'مثال: يعقوب خالد',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                hintText: 'مثال: 771234567',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
          ],

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              hintText: 'مثال: user@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: _isLoading ? null : _submitAuth,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(_isRegistering ? 'إنشاء الحساب الآن' : 'تسجيل الدخول'),
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isRegistering = !_isRegistering;
                  _errorMessage = null;
                });
              },
              child: Text(
                _isRegistering ? 'لديك حساب بالفعل؟ تسجيل الدخول' : 'ليس لديك حساب؟ إنشاء حساب جديد',
                style: const TextStyle(color: PharmaTheme.primaryGreenDark, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 20, color: PharmaTheme.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitle, style: const TextStyle(color: PharmaTheme.textMuted, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
