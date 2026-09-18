import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/models/medicine_search_model.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/medicine_details_screen.dart';
import 'presentation/screens/my_reservations_screen.dart';
import 'presentation/screens/pharmacy_api_screen.dart';
import 'presentation/screens/profile_screen.dart';

void main() {
  runApp(const PharmaConnectApp());
}

class PharmaConnectApp extends StatefulWidget {
  const PharmaConnectApp({super.key});

  @override
  State<PharmaConnectApp> createState() => _PharmaConnectAppState();
}

class _PharmaConnectAppState extends State<PharmaConnectApp> {
  @override
  void initState() {
    super.initState();
    ThemeController().addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeController().removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: PharmaTheme.lightTheme,
      darkTheme: PharmaTheme.darkTheme,
      themeMode: ThemeController().themeMode,
      locale: const Locale('ar', 'YE'),
      supportedLocales: const [
        Locale('ar', 'YE'),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ApiService().isAuthenticated ? const HomeScreen() : const AuthScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<MedicineSearchItem> _searchResults = [];
  bool _isLoading = false;
  Timer? _badgeTicker;

  final List<String> _popularKeywords = [
    'Panadol Extra',
    'Augmentin',
    'Brufen',
    'Norvasc',
  ];

  @override
  void initState() {
    super.initState();
    // تحديث Badge الحجوزات كل ثانية (لتحديث العداد التنازلي)
    _badgeTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // استماع لتغييرات الحجوزات من ApiService
    ApiService().addListener(_onApiChange);
  }

  void _onApiChange() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchMedicines([String? query]) async {
    final cleanQuery = query?.trim() ?? '';
    if (cleanQuery.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final results = await ApiService().searchMedicines(query: cleanQuery);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  void _onQuickSearch(String keyword) {
    _searchController.text = keyword;
    _fetchMedicines(keyword);
  }

  @override
  void dispose() {
    _badgeTicker?.cancel();
    ApiService().removeListener(_onApiChange);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildAppDrawer(context),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: ThemeController().isDarkMode ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreenDark,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ThemeController().isDarkMode ? const Color(0xFF064E3B) : PharmaTheme.mintAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_pharmacy, color: PharmaTheme.primaryGreen, size: 18),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                AppConstants.appName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              ThemeController().isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
              color: ThemeController().isDarkMode ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreenDark,
              size: 22,
            ),
            tooltip: ThemeController().isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
            onPressed: () {
              ThemeController().toggleTheme();
            },
          ),
        ],
      ),
      body: _currentTabIndex == 0
          ? _buildSearchBody()
          : _currentTabIndex == 1
              ? const MyReservationsScreen()
              : const ProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        selectedItemColor: ThemeController().isDarkMode ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen,
        unselectedItemColor: PharmaTheme.textMuted,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'البحث عن الأدوية',
          ),
          BottomNavigationBarItem(
            icon: ApiService().activeReservationsCount > 0
                ? Badge(
                    label: Text('${ApiService().activeReservationsCount}'),
                    child: const Icon(Icons.receipt_long_rounded),
                  )
                : const Icon(Icons.receipt_long_rounded),
            label: 'طلباتي وحجوزاتي',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    final user = ApiService().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen;
    final textMain = isDark ? PharmaTheme.darkTextMain : PharmaTheme.textMain;
    final textMuted = isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted;
    final surfaceBg = isDark ? PharmaTheme.darkSurface : Colors.white;

    return Drawer(
      backgroundColor: isDark ? PharmaTheme.darkBackground : const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // ================= ترويسة القائمة الجانبية الطبية الفاخرة =================
          Container(
            padding: const EdgeInsets.fromLTRB(16, 44, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
                    : [PharmaTheme.primaryGreen, PharmaTheme.primaryGreenDark],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 50 : 25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_pharmacy, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'PharmaConnect',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'إغلاق القائمة',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(180), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Text(
                          user != null && user.name.isNotEmpty
                              ? user.name.substring(0, 1).toUpperCase()
                              : 'ف',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: PharmaTheme.primaryGreenDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'زائر PharmaConnect',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email ?? 'وضع التصفح والبحث السريع',
                            style: TextStyle(
                              color: Colors.white.withAlpha(210),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withAlpha(60)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user != null ? Icons.verified_rounded : Icons.explore_rounded,
                                  color: isDark ? PharmaTheme.darkNeonGreen : Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  user != null ? 'عميل موثّق ومعتمد' : 'تصفح كزائر',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= قائمة الخيارات المنظمة =================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerSectionTitle('التنقل السريع والرئيسي', textMuted),
                _buildDrawerItem(
                  icon: Icons.search_rounded,
                  title: 'البحث عن الأدوية',
                  subtitle: 'الاستعلام اللحظي والوفرة في الصيدليات',
                  isSelected: _currentTabIndex == 0,
                  activeColor: activeColor,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentTabIndex = 0);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_rounded,
                  title: 'طلباتي وحجوزاتي',
                  subtitle: 'متابعة الأدوية وتذاكر الحجز والـ QR',
                  isSelected: _currentTabIndex == 1,
                  activeColor: activeColor,
                  isDark: isDark,
                  badgeText: ApiService().activeReservationsCount > 0
                      ? '${ApiService().activeReservationsCount}'
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentTabIndex = 1);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'الملف الشخصي والإعدادات',
                  subtitle: 'تعديل البيانات والمدينة والتفضيلات',
                  isSelected: _currentTabIndex == 2,
                  activeColor: activeColor,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentTabIndex = 2);
                  },
                ),

                const SizedBox(height: 10),
                _buildDrawerSectionTitle('المظهر والتفضيلات', textMuted),
                
                // بطاقة مفتاح الثيم الليلي الأنيقة
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: surfaceBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF064E3B).withAlpha(120)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          ThemeController().isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: ThemeController().isDarkMode ? PharmaTheme.darkNeonGreen : const Color(0xFFD97706),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المظهر الليلي',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: textMain,
                              ),
                            ),
                            Text(
                              ThemeController().isDarkMode ? 'مفعل (الداكن الطبي)' : 'معطل (النهاري الطبي)',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: ThemeController().isDarkMode,
                        activeTrackColor: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen,
                        onChanged: (val) {
                          setState(() {
                            ThemeController().toggleTheme();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                _buildDrawerSectionTitle('المعلومات والدعم الفني', textMuted),
                _buildDrawerItem(
                  icon: Icons.timer_outlined,
                  title: 'مهلة الحجز (TTL 30 دقيقة)',
                  subtitle: 'آلية عمل قفل الحجز وفك المخزون التلقائي',
                  isSelected: false,
                  activeColor: activeColor,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    _showTtlInfoDialog(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.api_rounded,
                  title: 'ربط الصيدلية بـ PharmaConnect',
                  subtitle: 'طلب مفتاح API لمزامنة المخزون (B2B)',
                  isSelected: false,
                  activeColor: activeColor,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => const PharmacyApiScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.support_agent_rounded,
                  title: 'مركز الدعم والمساعدة',
                  subtitle: 'التواصل مع فريق الدعم الفني',
                  isSelected: false,
                  activeColor: activeColor,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    _showSupportDialog(context);
                  },
                ),
              ],
            ),
          ),

          // ================= تذييل القائمة الجانبية (تسجيل الخروج والإصدار) =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceBg,
              border: Border(
                top: BorderSide(
                  color: isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              children: [
                if (user != null)
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await ApiService().logout();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthScreen()),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: PharmaTheme.statusDanger, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'تسجيل الخروج من الحساب',
                            style: TextStyle(
                              color: PharmaTheme.statusDanger,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 42),
                      backgroundColor: PharmaTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text('تسجيل الدخول / إنشاء حساب'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                Text(
                  'PharmaConnect v2.13.0 • رعاية صحية رقمية',
                  style: TextStyle(color: textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 18, left: 18, top: 8, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color activeColor,
    required bool isDark,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    final bgColor = isSelected
        ? (isDark ? const Color(0xFF064E3B).withAlpha(160) : PharmaTheme.mintBackground)
        : Colors.transparent;
    final borderColor = isSelected
        ? (isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen)
        : Colors.transparent;
    final textMain = isDark ? PharmaTheme.darkTextMain : PharmaTheme.textMain;
    final textMuted = isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? PharmaTheme.darkNeonGreen.withAlpha(40) : PharmaTheme.mintAccent)
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? activeColor : textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          fontSize: 14,
                          color: isSelected ? activeColor : textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: textMuted),
                      ),
                    ],
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTtlInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.timer_outlined, color: PharmaTheme.primaryGreen),
            SizedBox(width: 8),
            Text('مهلة الحجز (TTL)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'تمنحك الصيدلية مهلة افتراضية قدرها 30 دقيقة عند حجز أي دواء.\n\nخلال هذه الفترة، يتم تطبيق قفل تشاؤمي لمنع حجز الكمية لمستخدم آخر، وفي حال عدم الاستلام خلال المهلة يتم فك الحجز تلقائياً وإعادة الصنف للمخزون العام.',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً، فهمت ذلك'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.support_agent_rounded, color: PharmaTheme.primaryGreen),
            SizedBox(width: 8),
            Text('مركز المساعدة والدعم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'نظام فارما-كونكت (PharmaConnect) يربط الصيدليات بالمستخدمين لحظياً.\n\n• للشكاوى والاستفسارات: support@pharmaconnect.ye\n• لربط أنظمة الصيدليات المحاسبية (B2B Integration): api@pharmaconnect.ye\n• الهاتف المباشر: +967 1 400000',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      onRefresh: () => _fetchMedicines(_searchController.text),
      color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ترويسة البحث
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF065F46), const Color(0xFF0F172A)]
                      : [PharmaTheme.primaryGreen, PharmaTheme.primaryGreenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : PharmaTheme.primaryGreen).withAlpha(40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ابحث عن دوائك الآن',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'تحقق لحظياً من الصيدليات المتوفر لديها الدواء وأقربها إليك',
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    onChanged: (val) {
                      _fetchMedicines(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'اكتب اسم الدواء التجاري أو العلمي...',
                      hintStyle: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: isDark ? Colors.white70 : PharmaTheme.textMuted,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _fetchMedicines('');
                              },
                            )
                          : Icon(
                              Icons.filter_list,
                              color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen,
                            ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : Colors.transparent,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_searchController.text.trim().isEmpty) ...[
              _buildPreSearchState(),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'نتائج البحث عن «${_searchController.text.trim()}»',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? PharmaTheme.darkTextMain : PharmaTheme.textMain,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${_searchResults.length} نتائج',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: PharmaTheme.primaryGreen),
                  ),
                )
              else if (_searchResults.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد أدوية متطابقة مع «${_searchController.text.trim()}» حالياً',
                          style: const TextStyle(color: PharmaTheme.textMuted, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return _buildMedicineCard(item);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreSearchState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 6),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : PharmaTheme.mintAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.manage_search_rounded,
                  color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreenDark,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ابدأ بالبحث عن دوائك',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? PharmaTheme.darkTextMain : PharmaTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اكتب اسم الدواء في مربع البحث أعلاه أو اضغط على أحد الأدوية الشائعة أدناه للتحقق من توفره في الصيدليات القريبة منك.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'أدوية شائعة للبحث السريع',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? PharmaTheme.darkTextMain : PharmaTheme.textMain,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _popularKeywords.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final keyword = _popularKeywords[index];
            return InkWell(
              onTap: () => _onQuickSearch(keyword),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFBBF7D0),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 18,
                      color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreenDark,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        keyword,
                        style: TextStyle(
                          color: isDark ? PharmaTheme.darkTextMain : PharmaTheme.primaryGreenDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMedicineCard(MedicineSearchItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0);
    final cardBg = isDark ? PharmaTheme.darkSurface : Colors.white;
    final isAvailable = item.status == 'available';
    final imageUrl = item.medicine.imageUrl;

    return GestureDetector(
      onTap: () async {
        final reserved = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineDetailsScreen(item: item),
          ),
        );
        if (reserved == true && mounted) {
          _fetchMedicines(_searchController.text);
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 6),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الدواء في الأعلى
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => _buildMedicineImagePlaceholder(isDark),
                )
              )
            else
              _buildMedicineImagePlaceholder(isDark),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم الدواء والحالة
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.medicine.tradeName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? PharmaTheme.darkTextMain : PharmaTheme.textMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.medicine.scientificName,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? (isDark ? const Color(0xFF064E3B) : PharmaTheme.mintAccent)
                              : (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isAvailable ? '${item.availableQuantity} علبة' : 'غير متوفر',
                          style: TextStyle(
                            color: isAvailable
                                ? (isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreenDark)
                                : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // بيانات الصيدلية
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_pharmacy_rounded,
                                size: 15,
                                color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.pharmacy.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? PharmaTheme.darkTextMain : PharmaTheme.textMain,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.distanceKm != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.near_me_rounded,
                                      size: 13,
                                      color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item.distanceKm!.toStringAsFixed(1)} كم',
                                    style: TextStyle(
                                      color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: 13,
                                color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.pharmacy.address,
                                style: TextStyle(
                                  color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // السعر وزر الحجز
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السعر',
                            style: TextStyle(
                              color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${item.price.toStringAsFixed(0)} ${item.currency}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineDetailsScreen(item: item),
                            ),
                          );
                        },
                        icon: const Icon(Icons.lock_clock_rounded, size: 16),
                        label: const Text('حجز (30 دقيقة)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineImagePlaceholder(bool isDark) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
              : [PharmaTheme.mintAccent, PharmaTheme.mintBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.medication_rounded,
          size: 48,
          color: isDark ? PharmaTheme.darkNeonGreen.withAlpha(160) : PharmaTheme.primaryGreen.withAlpha(120),
        ),
      ),
    );
  }
}
