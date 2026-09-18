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
