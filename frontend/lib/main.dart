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

  final List<String> _popularKeywords = [
    'Panadol Extra',
    'Augmentin',
    'Brufen',
    'Norvasc',
  ];

  @override
  void initState() {
    super.initState();
    // لا يتم جلب النتائج قبل أن يبدأ المستخدم بالبحث
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildAppDrawer(context),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: PharmaTheme.mintAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_pharmacy, color: PharmaTheme.primaryGreen, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              ThemeController().isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
              color: ThemeController().isDarkMode ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreenDark,
            ),
            tooltip: ThemeController().isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
            onPressed: () {
              ThemeController().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'حجوزاتي',
            onPressed: () {
              setState(() {
                _currentTabIndex = 1;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'حسابي',
            onPressed: () {
              setState(() {
                _currentTabIndex = 2;
              });
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'البحث عن الأدوية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'طلباتي وحجوزاتي',
          ),
          BottomNavigationBarItem(
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
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : PharmaTheme.textMuted;

    return Drawer(
      backgroundColor: isDark ? PharmaTheme.darkBackground : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ترويسة القائمة الجانبية بهوية العميل
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF065F46), const Color(0xFF0F172A)]
                    : [PharmaTheme.primaryGreen, PharmaTheme.primaryGreenDark],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withAlpha(220),
                  child: Text(
                    user != null && user.name.isNotEmpty
                        ? user.name.substring(0, 1).toUpperCase()
                        : 'ف',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: PharmaTheme.primaryGreenDark,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user?.name ?? 'زائر PharmaConnect',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'وضع التصفح والبحث المباشر',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user != null ? Icons.verified_rounded : Icons.explore_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user != null ? 'عميل موثّق ومعتمد' : 'تصفح واستعلام كزائر',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // عناصر القائمة الجانبية
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.search_rounded, color: _currentTabIndex == 0 ? activeColor : inactiveColor),
            title: const Text('البحث عن الأدوية', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('الاستعلام اللحظي والوفرة في الصيدليات', style: TextStyle(fontSize: 12)),
            selected: _currentTabIndex == 0,
            selectedTileColor: activeColor.withAlpha(20),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentTabIndex = 0);
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt_long_rounded, color: _currentTabIndex == 1 ? activeColor : inactiveColor),
            title: const Text('طلباتي وحجوزاتي', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('متابعة الأدوية وتذاكر الحجز والـ QR', style: TextStyle(fontSize: 12)),
            selected: _currentTabIndex == 1,
            selectedTileColor: activeColor.withAlpha(20),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentTabIndex = 1);
            },
          ),
          ListTile(
            leading: Icon(Icons.person_outline_rounded, color: _currentTabIndex == 2 ? activeColor : inactiveColor),
            title: const Text('الملف الشخصي والإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('تعديل البيانات الشخصية، والمدينة', style: TextStyle(fontSize: 12)),
            selected: _currentTabIndex == 2,
            selectedTileColor: activeColor.withAlpha(20),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentTabIndex = 2);
            },
          ),
          const Divider(indent: 16, endIndent: 16),

          // مفتاح التبديل للمظهر الليلي والنهاري
          SwitchListTile(
            secondary: Icon(
              ThemeController().isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: ThemeController().isDarkMode ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreenDark,
            ),
            title: const Text('المظهر الليلي (Dark Mode)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              ThemeController().isDarkMode ? 'مفعل (الثيم الطبي الداكن)' : 'معطل (الثيم النهاري الطبي)',
              style: const TextStyle(fontSize: 12),
            ),
            value: ThemeController().isDarkMode,
            onChanged: (val) {
              setState(() {
                ThemeController().toggleTheme();
              });
            },
          ),

          ListTile(
            leading: Icon(Icons.timer_outlined, color: inactiveColor),
            title: const Text('صلاحية الحجز (TTL 30 دقيقة)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('كيفية عمل مهلة الاستلام وقفل التزامن', style: TextStyle(fontSize: 12)),
            onTap: () {
              Navigator.pop(context);
              _showTtlInfoDialog(context);
            },
          ),

          ListTile(
            leading: Icon(Icons.support_agent_rounded, color: inactiveColor),
            title: const Text('الدعم الفني والربط البرمجي', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('مساعدة الصيدليات والعملاء (B2B / Help)', style: TextStyle(fontSize: 12)),
            onTap: () {
              Navigator.pop(context);
              _showSupportDialog(context);
            },
          ),

          const Divider(indent: 16, endIndent: 16),

          // خيار تسجيل الدخول أو الخروج
          if (user != null)
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: PharmaTheme.statusDanger),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: PharmaTheme.statusDanger, fontWeight: FontWeight.bold),
              ),
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
            )
          else
            ListTile(
              leading: const Icon(Icons.login_rounded, color: PharmaTheme.primaryGreen),
              title: const Text(
                'تسجيل الدخول / إنشاء حساب',
                style: TextStyle(color: PharmaTheme.primaryGreen, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
            ),
          const SizedBox(height: 20),
        ],
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
                    onChanged: (val) {
                      _fetchMedicines(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'اكتب اسم الدواء التجاري أو العلمي...',
                      prefixIcon: const Icon(Icons.search, color: PharmaTheme.primaryGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: PharmaTheme.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                _fetchMedicines('');
                              },
                            )
                          : const Icon(Icons.filter_list, color: PharmaTheme.primaryGreen),
                      filled: true,
                      fillColor: Colors.white,
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
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: PharmaTheme.textMain,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${_searchResults.length} نتائج',
                    style: const TextStyle(
                      fontSize: 13,
                      color: PharmaTheme.textMuted,
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _popularKeywords.map((keyword) {
            return ActionChip(
              avatar: Icon(
                Icons.medication_outlined,
                size: 16,
                color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreenDark,
              ),
              label: Text(
                keyword,
                style: TextStyle(
                  color: isDark ? PharmaTheme.darkTextMain : PharmaTheme.primaryGreenDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
              side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFBBF7D0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () => _onQuickSearch(keyword),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMedicineCard(MedicineSearchItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicineDetailsScreen(item: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.medicine.tradeName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? PharmaTheme.darkTextMain : PharmaTheme.textMain,
                        ),
                      ),
                      Text(
                        item.medicine.scientificName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.status == 'available'
                          ? (isDark ? const Color(0xFF064E3B) : PharmaTheme.mintAccent)
                          : (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'متوفر ${item.availableQuantity} علبة',
                      style: TextStyle(
                        color: item.status == 'available'
                            ? (isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreenDark)
                            : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.local_pharmacy,
                    size: 16,
                    color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.pharmacy.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? PharmaTheme.darkTextMain : PharmaTheme.textMain,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.distanceKm != null) ...[
                    Icon(
                      Icons.near_me,
                      size: 14,
                      color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${item.distanceKm} كم',
                      style: TextStyle(
                        color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.pharmacy.address,
                      style: TextStyle(
                        color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Divider(height: 20, color: isDark ? PharmaTheme.darkBorder : const Color(0xFFE2E8F0)),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 10,
                spacing: 8,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'السعر الرسمي',
                        style: TextStyle(
                          color: isDark ? PharmaTheme.darkTextMuted : PharmaTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${item.price.toStringAsFixed(0)} ${item.currency}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? PharmaTheme.darkNeonGreen : PharmaTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicineDetailsScreen(item: item),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock_clock, size: 16),
                    label: const Text('حجز مؤقت (30 دقيقة)'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
