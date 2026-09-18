import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
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

    bool success = false;
    if (_isRegistering) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      if (name.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'يرجى إدخال الاسم الكامل للمريض';
        });
        return;
      }
      success = await ApiService().register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
    } else {
      success = await ApiService().login(email, password);
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'بيانات الدخول غير صحيحة أو تعذر الاتصال بالخادم.';
      });
    }
  }

  void _continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // شعار المنصة الطبية
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: PharmaTheme.mintAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: PharmaTheme.primaryGreen.withAlpha(40),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_pharmacy_rounded,
                      size: 52,
                      color: PharmaTheme.primaryGreenDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: PharmaTheme.primaryGreenDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'المنصة الذكية لتتبع وفرة الأدوية وإدارة الحجوزات',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: PharmaTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 28),

                  // بطاقة تسجيل الدخول أو إنشاء الحساب
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // أزرار التبديل العلوية (Tab Switcher)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isRegistering = false;
                                      _errorMessage = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !_isRegistering ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: !_isRegistering
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(10),
                                                blurRadius: 4,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      'تسجيل الدخول',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: !_isRegistering ? PharmaTheme.primaryGreenDark : PharmaTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isRegistering = true;
                                      _errorMessage = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isRegistering ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _isRegistering
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(10),
                                                blurRadius: 4,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      'إنشاء حساب جديد',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: _isRegistering ? PharmaTheme.primaryGreenDark : PharmaTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

                        // حقول إنشاء الحساب الإضافية
                        if (_isRegistering) ...[
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'الاسم الكامل للمريض',
                              hintText: 'مثال: يعقوب خالد',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'رقم الهاتف للتواصل',
                              hintText: 'مثال: 771234567',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // حقول البريد وكلمة المرور
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            hintText: 'مثال: patient@pharmaconnect.ye',
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

                        // زر الإرسال
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _isLoading ? null : _submitAuth,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  _isRegistering ? 'إنشاء الحساب والدخول' : 'تسجيل الدخول الآن',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // زر الدخول كزائر / استعلام مباشر
                  TextButton.icon(
                    onPressed: _continueAsGuest,
                    icon: const Icon(Icons.arrow_back, size: 16, color: PharmaTheme.textMuted),
                    label: const Text(
                      'المتابعة كزائر والبحث عن الأدوية مباشرة',
                      style: TextStyle(color: PharmaTheme.textMuted, fontSize: 13, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
