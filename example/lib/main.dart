import 'package:adaptive_selector_example/push_behavior_for_side_sheets.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_selector/adaptive_selector.dart';

import 'contextual_push_for_overlay_side_sheets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final ValueNotifier<bool> isRTL = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isRTL,
      builder: (context, rtl, _) {
        return MaterialApp(
          title: 'Adaptive Selector Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          locale: rtl ? const Locale('ar', 'EG') : const Locale('en', 'US'),
          builder: (context, child) {
            return Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                children: [
                  const PublicDrawer(),
                  Expanded(child: child!),
                ],
              ),
            );
          },
          home: const MyHomePage(),
        );
      },
    );
  }
}

class PublicDrawer extends StatelessWidget {
  const PublicDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 300);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedFruit;
  String? selectedCountry;
  int? selectedNumber;
  String? selectedAsyncItem;
  String? selectedForcedMobile;
  String? selectedForcedDesktop;
  String? selectedLeftSheet;
  String? selectedRightSheet;
  String? selectedSmallSheet;
  String? selectedLargeSheet;
  String? selectedFullSheet;
  String? selectedAdvanced;
  String? selectedWithSafeArea;
  String? selectedWithoutSafeArea;

  // Anchored panel examples
  late LayerLink _calendarAnchorLink;
  String? selectedTimeSlot;
  final List<String> timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  // Programmatic show.* examples
  late LayerLink _dropdownAnchorLink;
  final GlobalKey _dropdownRectKey = GlobalKey();
  String? selectedDropdownViaLink;
  String? selectedDropdownViaRect;

  // Enhanced customBuilder examples
  late LayerLink _dropdownEnhancedLink;
  String? selectedFruitEnhanced;
  late LayerLink _dropdownMultiSelectLink;
  Set<String> selectedCountriesMulti = {};
  final GlobalKey _dropdownActionsKey = GlobalKey();
  String? selectedAction;

  // Programmatic show.*: dropdownOrSheet examples
  late LayerLink _dropdownOrSheetLinkSimple;
  final GlobalKey _dropdownOrSheetRectKeySimple = GlobalKey();
  final GlobalKey _dropdownOrSheetRectKeyCustom = GlobalKey();
  String? selectedDropdownOrSheetSimple;
  String? selectedDropdownOrSheetCustom;

  final List<String> fruits = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew',
    'Kiwi',
    'Lemon',
    'Mango',
    'Orange',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize LayerLink in initState to prevent hot reload issues
    _calendarAnchorLink = LayerLink();
    _dropdownAnchorLink = LayerLink();
    _dropdownEnhancedLink = LayerLink();
    _dropdownMultiSelectLink = LayerLink();
    _dropdownOrSheetLinkSimple = LayerLink();
  }

  final List<String> countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Japan',
    'Brazil',
    'India',
    'China',
    'Mexico',
    'Italy',
    'Spain',
    'South Korea',
    'Netherlands',
  ];

  final List<int> numbers = List.generate(50, (index) => index + 1);

  // Simulated async data
  final List<String> _asyncData = [
    'Async Item 1',
    'Async Item 2',
    'Async Item 3',
    'Async Item 4',
    'Async Item 5',
    'Remote Data A',
    'Remote Data B',
    'Remote Data C',
  ];

  /// Simulates an async search operation (e.g., API call)
  Future<List<String>> _performAsyncSearch(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (query.isEmpty) {
      return _asyncData;
    }

    // Filter results based on query
    return _asyncData
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Adaptive Selector Demo'),
        actions: [
          // RTL/LTR Toggle Button
          ValueListenableBuilder<bool>(
            valueListenable: _MyAppState.isRTL,
            builder: (context, rtl, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Text(
                      rtl ? 'RTL' : 'LTR',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: rtl,
                      onChanged: (value) {
                        _MyAppState.isRTL.value = value;
                      },
                      activeThumbColor: Colors.green,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Basic Selector'),
            const Text(
              'Simple selector without search',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: fruits,
              selectedValue: selectedFruit,
              onChanged: (value) {
                setState(() {
                  selectedFruit = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'Select a fruit',
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('2. Selector with Synchronous Search'),
            const Text(
              'Search filters options locally',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: countries,
              selectedValue: selectedCountry,
              onChanged: (value) {
                setState(() {
                  selectedCountry = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'Select a country',
              enableSearch: true,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('3. Custom Styled Selector with Animations'),
            const Text(
              'Custom colors and smooth dropdown animations',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<int>(
              options: numbers,
              selectedValue: selectedNumber,
              onChanged: (value) {
                setState(() {
                  selectedNumber = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text('Number $item'),
              hint: 'Pick a number',
              enableSearch: true,
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFF5F5F5),
                selectedItemColor: Color(0xFFE3F2FD),
                selectedTextColor: Color(0xFF1976D2),
                textColor: Color(0xFF424242),
                borderRadius: BorderRadius.all(Radius.circular(12)),
                animationDuration: Duration(milliseconds: 300),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('4. Asynchronous Search (Simulated API)'),
            const Text(
              'Search performs async operations with loading states',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: _asyncData,
              selectedValue: selectedAsyncItem,
              onChanged: (value) {
                setState(() {
                  selectedAsyncItem = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Row(
                children: [
                  const Icon(Icons.cloud, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
              hint: 'Search remote data...',
              enableSearch: true,
              onSearch: _performAsyncSearch,
              style: const AdaptiveSelectorStyle(
                selectedItemColor: Color(0xFFE8F5E9),
                selectedTextColor: Color(0xFF2E7D32),
                searchIcon: Icon(Icons.search, color: Colors.green),
              ),
              dropdownHeaderWidget: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Remote Data Source',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              dropdownFooterWidget: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Text(
                  '${_asyncData.length} items available',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('5. Force Mobile UI (Always Bottom Sheet)'),
            const Text(
              'Always uses bottom sheet, even on large screens',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: fruits,
              selectedValue: selectedForcedMobile,
              onChanged: (value) {
                setState(() {
                  selectedForcedMobile = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'Always shows bottom sheet',
              mode: AdaptiveSelectorMode.alwaysMobile,
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFFFF3E0),
                selectedItemColor: Color(0xFFFFE0B2),
                selectedTextColor: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('6. Force Desktop UI (Always Dropdown)'),
            const Text(
              'Always uses dropdown overlay, even on small screens',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: countries.take(10).toList(),
              selectedValue: selectedForcedDesktop,
              onChanged: (value) {
                setState(() {
                  selectedForcedDesktop = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'Always shows dropdown',
              mode: AdaptiveSelectorMode.alwaysDesktop,
              enableSearch: true,
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFE8EAF6),
                selectedItemColor: Color(0xFFC5CAE9),
                selectedTextColor: Color(0xFF283593),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('7. Left Side Sheet'),
            const Text(
              'Sheet slides in from the left side (drawer-style)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: fruits.take(8).toList(),
              selectedValue: selectedLeftSheet,
              onChanged: (value) {
                setState(() {
                  selectedLeftSheet = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'Select from left sheet',
              mode: AdaptiveSelectorMode.leftSheet,
              enableSearch: true,
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFE1F5FE),
                selectedItemColor: Color(0xFFB3E5FC),
                selectedTextColor: Color(0xFF01579B),
              ),
              dropdownHeaderWidget: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.cyan.shade100),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_forward, size: 16, color: Colors.cyan),
                    SizedBox(width: 8),
                    Text(
                      'Slides from Left',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('8. Right Side Sheet'),
            const Text(
              'Sheet slides in from the right side (settings-style)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: countries.take(8).toList(),
              selectedValue: selectedRightSheet,
              onChanged: (value) {
                setState(() {
                  selectedRightSheet = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'Select from right sheet',
              mode: AdaptiveSelectorMode.rightSheet,
              enableSearch: true,
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFF3E5F5),
                selectedItemColor: Color(0xFFE1BEE7),
                selectedTextColor: Color(0xFF4A148C),
              ),
              dropdownFooterWidget: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.purple.shade100),
                  ),
                ),
                child: const Text(
                  'Swipe or tap outside to close',
                  style: TextStyle(fontSize: 11, color: Colors.purple),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('9. Small Side Sheet (Compact)'),
            const Text(
              'Small width - 60% of screen, max 280px',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: fruits.take(6).toList(),
              selectedValue: selectedSmallSheet,
              onChanged: (value) {
                setState(() {
                  selectedSmallSheet = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'Select from small sheet',
              mode: AdaptiveSelectorMode.leftSheet,
              sideSheetSize: SideSheetSize.small,
              enableSearch: true,
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFFFF3E0),
                selectedItemColor: Color(0xFFFFE0B2),
                selectedTextColor: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('10. Large Side Sheet (Detailed)'),
            const Text(
              'Large width - 90% of screen, max 560px',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: countries.take(10).toList(),
              selectedValue: selectedLargeSheet,
              onChanged: (value) {
                setState(() {
                  selectedLargeSheet = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'Select from large sheet',
              mode: AdaptiveSelectorMode.rightSheet,
              sideSheetSize: SideSheetSize.large,
              enableSearch: true,
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFE8F5E9),
                selectedItemColor: Color(0xFFC8E6C9),
                selectedTextColor: Color(0xFF1B5E20),
              ),
              dropdownHeaderWidget: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.green.shade100),
                  ),
                ),
                child: const Text(
                  '🌍 Select Your Country',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('11. Full-Width Side Sheet'),
            const Text(
              'Full width - 100% of screen (immersive)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: fruits,
              selectedValue: selectedFullSheet,
              onChanged: (value) {
                setState(() {
                  selectedFullSheet = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'Select from full sheet',
              mode: AdaptiveSelectorMode.leftSheet,
              sideSheetSize: SideSheetSize.full,
              enableSearch: true,
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFFCE4EC),
                selectedItemColor: Color(0xFFF8BBD0),
                selectedTextColor: Color(0xFF880E4F),
              ),
              dropdownFooterWidget: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  border: Border(top: BorderSide(color: Colors.pink.shade100)),
                ),
                child: const Text(
                  'Full-screen selection experience',
                  style: TextStyle(fontSize: 12, color: Colors.pink),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('12. Advanced: All Features Combined'),
            const Text(
              'Custom size + header/footer + styling + async search',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: countries,
              selectedValue: selectedAdvanced,
              onChanged: (value) {
                setState(() {
                  selectedAdvanced = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(item),
                  ],
                ),
              ),
              hint: 'Advanced selector',
              mode: AdaptiveSelectorMode.rightSheet,
              sideSheetSize: SideSheetSize.large,
              enableSearch: true,
              onSearch: (query) async {
                // Simulate async search with delay
                await Future.delayed(const Duration(milliseconds: 500));
                return countries
                    .where(
                      (country) =>
                          country.toLowerCase().contains(query.toLowerCase()),
                    )
                    .toList();
              },
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFE3F2FD),
                selectedItemColor: Color(0xFFBBDEFB),
                selectedTextColor: Color(0xFF0D47A1),
                textColor: Color(0xFF1565C0),
              ),
              dropdownHeaderWidget: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.blue.shade50],
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.blue.shade200),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.public, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Country Selector',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Search and select your country',
                      style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              dropdownFooterWidget: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border(top: BorderSide(color: Colors.blue.shade100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Powered by async search',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('13. SafeArea: Enabled (Default)'),
            const Text(
              'Respects device safe areas (notches, status bar, etc.)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: fruits.take(5).toList(),
              selectedValue: selectedWithSafeArea,
              onChanged: (value) {
                setState(() {
                  selectedWithSafeArea = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'With SafeArea (default)',
              mode: AdaptiveSelectorMode.bottomSheet,
              useSafeArea: true, // Default behavior
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFE8EAF6),
                selectedItemColor: Color(0xFFC5CAE9),
                selectedTextColor: Color(0xFF283593),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('14. SafeArea: Disabled (Full Bleed)'),
            const Text(
              'Content extends to screen edges (may overlap system UI)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            AdaptiveSelector<String>(
              options: fruits.take(5).toList(),
              selectedValue: selectedWithoutSafeArea,
              onChanged: (value) {
                setState(() {
                  selectedWithoutSafeArea = value;
                });
              },
              itemBuilder: (context, item, isSelected) => Text(item),
              hint: 'Without SafeArea',
              mode: AdaptiveSelectorMode.leftSheet,
              useSafeArea: false, // Disable SafeArea
              sideSheetSize: SideSheetSize.medium,
              style: const AdaptiveSelectorStyle(
                backgroundColor: Color(0xFFFFF8E1),
                selectedItemColor: Color(0xFFFFECB3),
                selectedTextColor: Color(0xFFF57F17),
              ),
            ),
            const SizedBox(height: 32),
            if (selectedFruit != null ||
                selectedCountry != null ||
                selectedNumber != null ||
                selectedAsyncItem != null ||
                selectedForcedMobile != null ||
                selectedForcedDesktop != null ||
                selectedLeftSheet != null ||
                selectedRightSheet != null ||
                selectedSmallSheet != null ||
                selectedLargeSheet != null ||
                selectedFullSheet != null ||
                selectedAdvanced != null ||
                selectedWithSafeArea != null ||
                selectedDropdownViaLink != null ||
                selectedDropdownViaRect != null ||
                selectedDropdownOrSheetSimple != null ||
                selectedDropdownOrSheetCustom != null ||
                selectedWithoutSafeArea != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Selected Values:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      if (selectedFruit != null)
                        _buildResultRow('Fruit', selectedFruit!),
                      if (selectedCountry != null)
                        _buildResultRow('Country', selectedCountry!),
                      if (selectedNumber != null)
                        _buildResultRow('Number', selectedNumber.toString()),
                      if (selectedAsyncItem != null)
                        _buildResultRow('Async Item', selectedAsyncItem!),
                      if (selectedForcedMobile != null)
                        _buildResultRow('Forced Mobile', selectedForcedMobile!),
                      if (selectedForcedDesktop != null)
                        _buildResultRow(
                          'Forced Desktop',
                          selectedForcedDesktop!,
                        ),
                      if (selectedLeftSheet != null)
                        _buildResultRow('Left Sheet', selectedLeftSheet!),
                      if (selectedRightSheet != null)
                        _buildResultRow('Right Sheet', selectedRightSheet!),
                      if (selectedSmallSheet != null)
                        _buildResultRow('Small Sheet', selectedSmallSheet!),
                      if (selectedLargeSheet != null)
                        _buildResultRow('Large Sheet', selectedLargeSheet!),
                      if (selectedFullSheet != null)
                        _buildResultRow('Full Sheet', selectedFullSheet!),
                      if (selectedAdvanced != null)
                        _buildResultRow('Advanced', selectedAdvanced!),
                      if (selectedWithSafeArea != null)
                        _buildResultRow('With SafeArea', selectedWithSafeArea!),
                      if (selectedWithoutSafeArea != null)
                        _buildResultRow(
                          'Without SafeArea',
                          selectedWithoutSafeArea!,
                        ),
                      if (selectedDropdownViaLink != null)
                        _buildResultRow(
                          'Programmatic Dropdown (Link)',
                          selectedDropdownViaLink!,
                        ),
                      if (selectedDropdownViaRect != null)
                        _buildResultRow(
                          'Programmatic Dropdown (Rect)',
                          selectedDropdownViaRect!,
                        ),
                      if (selectedDropdownOrSheetSimple != null)
                        _buildResultRow(
                          'dropdownOrSheet (Simple)',
                          selectedDropdownOrSheetSimple!,
                        ),
                      if (selectedDropdownOrSheetCustom != null)
                        _buildResultRow(
                          'dropdownOrSheet (Custom)',
                          selectedDropdownOrSheetCustom!,
                        ),
                      if (selectedTimeSlot != null)
                        _buildResultRow('Time Slot', selectedTimeSlot!),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Section 15: Anchored Panel Mode
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('15. Anchored Panel Mode'),
                    const SizedBox(height: 8),
                    const Text(
                      'The anchored panel mode allows the selector to appear positioned next to a specific widget (like a calendar cell or timeline item).',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Example: Calendar Time Slot Selector',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monday, January 15, 2024',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Click on a time slot to schedule:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          // Calendar grid with anchored selector
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // No need to wrap with CompositedTransformTarget!
                              // AdaptiveSelector handles it internally when anchorLink is provided.
                              AdaptiveSelector<String>(
                                options: timeSlots,
                                selectedValue: selectedTimeSlot,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTimeSlot = value;
                                  });
                                },
                                itemBuilder: (context, item, isSelected) =>
                                    Text(item),
                                anchorLink: _calendarAnchorLink,
                                anchorPosition: AnchorPosition.right,
                                anchorOffset: const Offset(8, 0),
                                anchorPanelWidth: 250,
                                enableSearch: true,
                                hint: 'Select Time',
                                style: const AdaptiveSelectorStyle(
                                  backgroundColor: Colors.white,
                                  selectedItemColor: Colors.deepPurple,
                                ),
                                headerWidget: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withValues(
                                      alpha: 0.1,
                                    ),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.deepPurple,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Available Time Slots',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (selectedTimeSlot != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Scheduled for $selectedTimeSlot',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Key Features:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Panel appears next to the trigger widget',
                      style: TextStyle(fontSize: 11),
                    ),
                    const Text(
                      '• Smart edge detection (auto-flips if no space)',
                      style: TextStyle(fontSize: 11),
                    ),
                    const Text(
                      '• Configurable position (right, left, top, bottom, auto)',
                      style: TextStyle(fontSize: 11),
                    ),
                    const Text(
                      '• Custom offset and panel width',
                      style: TextStyle(fontSize: 11),
                    ),
                    const Text(
                      '• Works with all existing features (search, header/footer, etc.)',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 16: Named Constructors API
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('16. Named Constructors API'),
                    const SizedBox(height: 8),
                    const Text(
                      'Use named constructors for a cleaner, more explicit API when you know which UI mode you want.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // sideSheet() constructor
                    const Text(
                      'AdaptiveSelector.sideSheet():',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AdaptiveSelector<String>.sideSheet(
                            isLeft: true,
                            options: fruits,
                            selectedValue: selectedFruit,
                            onChanged: (value) {
                              setState(() {
                                selectedFruit = value;
                              });
                            },
                            itemBuilder: (context, item, isSelected) =>
                                Text(item),
                            hint: 'Left Side Sheet',
                            sideSheetSize: SideSheetSize.medium,
                            style: const AdaptiveSelectorStyle(
                              backgroundColor: Colors.white,
                              selectedItemColor: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AdaptiveSelector<String>.sideSheet(
                            isLeft: false,
                            options: fruits,
                            selectedValue: selectedFruit,
                            onChanged: (value) {
                              setState(() {
                                selectedFruit = value;
                              });
                            },
                            itemBuilder: (context, item, isSelected) =>
                                Text(item),
                            hint: 'Right Side Sheet',
                            sideSheetSize: SideSheetSize.medium,
                            style: const AdaptiveSelectorStyle(
                              backgroundColor: Colors.white,
                              selectedItemColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // bottomSheet() constructor
                    const Text(
                      'AdaptiveSelector.bottomSheet():',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AdaptiveSelector<String>.bottomSheet(
                      options: fruits,
                      selectedValue: selectedFruit,
                      onChanged: (value) {
                        setState(() {
                          selectedFruit = value;
                        });
                      },
                      itemBuilder: (context, item, isSelected) => Text(item),
                      hint: 'Bottom Sheet',
                      enableSearch: true,
                      style: const AdaptiveSelectorStyle(
                        backgroundColor: Colors.white,
                        selectedItemColor: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // dropdown() constructor
                    const Text(
                      'AdaptiveSelector.dropdown():',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AdaptiveSelector<String>.dropdown(
                      options: fruits,
                      selectedValue: selectedFruit,
                      onChanged: (value) {
                        setState(() {
                          selectedFruit = value;
                        });
                      },
                      itemBuilder: (context, item, isSelected) => Text(item),
                      hint: 'Dropdown',
                      enableSearch: true,
                      dropdownHeaderWidget: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Select a fruit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      style: const AdaptiveSelectorStyle(
                        backgroundColor: Colors.white,
                        selectedItemColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Benefits:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• More explicit and readable code',
                      style: TextStyle(fontSize: 11),
                    ),
                    const Text(
                      '• IDE autocomplete shows only relevant parameters',
                      style: TextStyle(fontSize: 11),
                    ),
                    const Text(
                      '• No need to specify mode parameter',
                      style: TextStyle(fontSize: 11),
                    ),
                    const Text(
                      '• Backward compatible with existing mode parameter API',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 17: Push Behavior for Side Sheets
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('17. Push Behavior for Side Sheets'),
                    const SizedBox(height: 8),
                    const Text(
                      'Side sheets can push the main content aside (like a drawer) instead of appearing as an overlay.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'To use push behavior:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Wrap your page in a Scaffold with a GlobalKey',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '2. Set usePushBehavior: true',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '3. Pass the scaffoldKey parameter',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '4. Add the drawer content to Scaffold.drawer or Scaffold.endDrawer',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PushBehaviorExample(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open Push Behavior Example'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will open a new page demonstrating push behavior.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Section 18: Contextual Push Animation (Overlay)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      '18. Contextual Push Animation (Overlay)',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When opening a side sheet as an overlay, subtly shift the page content based on the sheet side.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContextualPushExample(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open Contextual Push Example'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This example uses useContextualPush + onContextualPushOffsetChanged + onContextualPushPivotYChanged to shift and hinge the page.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      '19. Programmatic API: show.dropdown (customBuilder)',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Open dropdown overlay programmatically anchored by LayerLink or measured Rect.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CompositedTransformTarget(
                          link: _dropdownAnchorLink,
                          child: ElevatedButton(
                            onPressed: () async {
                              await AdaptiveSelector.show.dropdown<String>(
                                context: context,
                                anchorLink: _dropdownAnchorLink,
                                panelWidth: 260,
                                anchorHeight: 40,
                                style: const AdaptiveSelectorStyle(),
                                onChanged: (v) =>
                                    setState(() => selectedDropdownViaLink = v),
                                customBuilder: (ctx, select, close) {
                                  final opts = fruits.take(6).toList();
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          'Custom Dropdown (Link)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Divider(height: 1),
                                      Flexible(
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: opts.length,
                                          separatorBuilder: (_, __) =>
                                              const Divider(height: 1),
                                          itemBuilder: (c, i) {
                                            final it = opts[i];
                                            return ListTile(
                                              dense: true,
                                              title: Text(it),
                                              onTap: () => select(it),
                                            );
                                          },
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: close,
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('Open (LayerLink)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          key: _dropdownRectKey,
                          onPressed: () async {
                            await AdaptiveSelector.show.dropdown<String>(
                              context: context,
                              selectorKey: _dropdownRectKey,
                              panelWidth: 260,
                              style: const AdaptiveSelectorStyle(),
                              onChanged: (v) =>
                                  setState(() => selectedDropdownViaRect = v),
                              customBuilder: (ctx, select, close) {
                                final opts = fruits.take(6).toList();
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        'Custom Dropdown (Rect)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    Flexible(
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: opts.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(height: 1),
                                        itemBuilder: (c, i) {
                                          final it = opts[i];
                                          return ListTile(
                                            dense: true,
                                            title: Text(it),
                                            onTap: () => select(it),
                                          );
                                        },
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: close,
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Open (Rect)'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedDropdownViaLink != null)
                      Text(
                        'Selected via Link: $selectedDropdownViaLink',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    if (selectedDropdownViaRect != null)
                      Text(
                        'Selected via Rect: $selectedDropdownViaRect',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Enhanced customBuilder examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Enhanced customBuilder Examples'),
                    const SizedBox(height: 8),
                    const Text(
                      'Comprehensive examples demonstrating customBuilder with icons, multi-select, and action menus.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    // Example 1: Enhanced UI with icons
                    const Text(
                      '1. Enhanced UI with Icons (Auto-close)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CompositedTransformTarget(
                      link: _dropdownEnhancedLink,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.apple, size: 18),
                        onPressed: () async {
                          await AdaptiveSelector.show.dropdown<String>(
                            context: context,
                            anchorLink: _dropdownEnhancedLink,
                            panelWidth: 280,
                            anchorHeight: 40,
                            autoCloseOnSelect: true,
                            onChanged: (v) =>
                                setState(() => selectedFruitEnhanced = v),
                            customBuilder: (ctx, select, close) {
                              final opts = fruits.take(6).toList();
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Header with close button
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.apple,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            'Select Your Fruit',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 20,
                                          ),
                                          onPressed: close,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  // Custom list with icons
                                  Flexible(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: opts.length,
                                      itemBuilder: (c, i) {
                                        final fruit = opts[i];
                                        final isSelected =
                                            fruit == selectedFruitEnhanced;
                                        return ListTile(
                                          dense: true,
                                          leading: Icon(
                                            Icons.check_circle,
                                            color: isSelected
                                                ? Colors.green
                                                : Colors.grey[300],
                                          ),
                                          title: Text(
                                            fruit,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          onTap: () => select(fruit),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        label: Text(selectedFruitEnhanced ?? 'Select Fruit'),
                      ),
                    ),
                    if (selectedFruitEnhanced != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Selected: $selectedFruitEnhanced',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Example 2: Multi-select
                    const Text(
                      '2. Multi-select (autoCloseOnSelect: false)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CompositedTransformTarget(
                      link: _dropdownMultiSelectLink,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.public, size: 18),
                        onPressed: () async {
                          await AdaptiveSelector.show.dropdown<String>(
                            context: context,
                            anchorLink: _dropdownMultiSelectLink,
                            panelWidth: 300,
                            isMultiSelect: true,
                            selectedValues: selectedCountriesMulti.toList(),
                            onSelectionChanged: (values) {
                              setState(() {
                                selectedCountriesMulti = values.toSet();
                              });
                            },
                            autoCloseOnSelect: false,
                            customBuilder: (ctx, select, close) {
                              final opts = countries.take(8).toList();
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Header
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'Select Countries',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${selectedCountriesMulti.length} selected',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  // Checkbox list
                                  Flexible(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: opts.length,
                                      itemBuilder: (c, i) {
                                        final country = opts[i];
                                        final isSelected =
                                            selectedCountriesMulti.contains(
                                              country,
                                            );
                                        return CheckboxListTile(
                                          dense: true,
                                          value: isSelected,
                                          title: Text(country),
                                          onChanged: (_) => select(country),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        label: Text(
                          selectedCountriesMulti.isEmpty
                              ? 'Select Countries'
                              : '${selectedCountriesMulti.length} selected',
                        ),
                      ),
                    ),
                    if (selectedCountriesMulti.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Selected: ${selectedCountriesMulti.join(", ")}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Example 3: Actions menu with Rect
                    const Text(
                      '3. Actions Menu (Rect anchoring)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      key: _dropdownActionsKey,
                      icon: const Icon(Icons.more_vert, size: 18),
                      onPressed: () async {
                        await AdaptiveSelector.show.dropdown<String>(
                          context: context,
                          selectorKey: _dropdownActionsKey,
                          panelWidth: 260,
                          verticalOffset: 8,
                          onChanged: (v) => setState(() => selectedAction = v),
                          customBuilder: (ctx, select, close) {
                            return Material(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quick Actions',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildActionButton(
                                      icon: Icons.edit,
                                      label: 'Edit',
                                      onTap: () => select('edit'),
                                    ),
                                    _buildActionButton(
                                      icon: Icons.share,
                                      label: 'Share',
                                      onTap: () => select('share'),
                                    ),
                                    _buildActionButton(
                                      icon: Icons.copy,
                                      label: 'Copy',
                                      onTap: () => select('copy'),
                                    ),
                                    _buildActionButton(
                                      icon: Icons.delete,
                                      label: 'Delete',
                                      color: Colors.red,
                                      onTap: () => select('delete'),
                                    ),
                                    const Divider(),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: close,
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      label: const Text('Actions'),
                    ),
                    if (selectedAction != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Action: $selectedAction',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Card(
              color: Color(0xFFFFF3E0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Features Demonstrated:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('✓ Adaptive UI (Mobile/Desktop)'),
                    Text('✓ Multiple presentation modes:'),
                    Text('  • Bottom Sheet (mobile)'),
                    Text('  • Dropdown (desktop)'),
                    Text('  • Left Side Sheet'),
                    Text('  • Right Side Sheet'),
                    Text('  • Anchored Panel (positioned next to trigger)'),
                    Text('✓ Configurable side sheet sizes:'),
                    Text('  • Small (60% width, max 280px)'),
                    Text('  • Medium (80% width, max 400px)'),
                    Text('  • Large (90% width, max 560px)'),
                    Text('  • Full (100% width)'),
                    Text('✓ Anchored panel features:'),
                    Text('  • Smart edge detection (auto-flips position)'),
                    Text(
                      '  • Configurable position (right, left, top, bottom, auto)',
                    ),
                    Text('  • Custom offset and panel width'),
                    Text('✓ SafeArea support:'),
                    Text(
                      '  • Enabled by default (respects notches/safe areas)',
                    ),
                    Text('  • Can be disabled for full-bleed layouts'),
                    Text('✓ Smooth animations for all modes'),
                    Text('✓ Synchronous search'),
                    Text('✓ Asynchronous search with loading'),
                    Text('✓ Custom styling'),
                    Text('✓ Scrollable long lists'),
                    Text('✓ Custom header/footer widgets'),
                    Text('✓ Dropdown stays open while typing'),
                    Text('✓ Named constructors API:'),
                    Text('  • AdaptiveSelector.sideSheet()'),
                    Text('  • AdaptiveSelector.bottomSheet()'),
                    Text('  • AdaptiveSelector.dropdown()'),
                    Text('✓ Push behavior for side sheets:'),
                    Text('  • Overlay mode (default)'),
                    Text('  • Push mode (drawer-like behavior)'),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      '20. Programmatic API: show.dropdownOrSheet',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adapts between dropdown (>= breakpoint) and bottom sheet (< breakpoint). Resize the window to see it switch.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Simple usage with options + header/footer + search:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CompositedTransformTarget(
                          link: _dropdownOrSheetLinkSimple,
                          child: ElevatedButton(
                            key: _dropdownOrSheetRectKeySimple,
                            onPressed: () async {
                              await AdaptiveSelector.show.dropdownOrSheet<
                                String
                              >(
                                context: context,
                                breakpoint: 600,
                                options: fruits.take(8).toList(),
                                selectedValue: selectedDropdownOrSheetSimple,
                                onChanged: (v) => setState(
                                  () => selectedDropdownOrSheetSimple = v,
                                ),
                                itemBuilder: (ctx, item, isSelected) =>
                                    Text(item),
                                enableSearch: true,
                                anchorLink: _dropdownOrSheetLinkSimple,
                                hint: 'Pick a fruit... ',
                                headerWidget: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Select a fruit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                footerWidget: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Tap outside or press Esc to close',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                // Anchors are used only in dropdown mode and ignored for bottom sheet
                                selectorKey: _dropdownOrSheetRectKeySimple,
                                panelWidth: 260,
                                verticalOffset: 6,
                              );
                            },
                            child: const Text('Open dropdownOrSheet (Simple)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Breakpoint = 600 px. Uses dropdown on wide screens and bottom sheet on narrow screens.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Advanced with customBuilder:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      key: _dropdownOrSheetRectKeyCustom,
                      onPressed: () async {
                        await AdaptiveSelector.show.dropdownOrSheet<String>(
                          context: context,
                          breakpoint: 600,
                          // You can still pass onChanged to receive the selected value
                          onChanged: (v) =>
                              setState(() => selectedDropdownOrSheetCustom = v),
                          customBuilder: (ctx, select, close) {
                            final opts = countries.take(6).toList();
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    8,
                                    8,
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Custom content',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Close',
                                        onPressed: close,
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                Flexible(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: opts.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (c, i) {
                                      final e = opts[i];
                                      return ListTile(
                                        dense: true,
                                        title: Text(e),
                                        onTap: () {
                                          select(e);
                                          // close(); // Not required: the panel closes after select() by default
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                          // Anchors are used only in dropdown mode and ignored for bottom sheet
                          selectorKey: _dropdownOrSheetRectKeyCustom,
                          panelWidth: 320,
                          verticalOffset: 6,
                        );
                      },
                      child: const Text('Open dropdownOrSheet (Custom)'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: anchorRect is used only in dropdown mode and ignored in bottom sheet mode.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // RTL/LTR Positioning Demo Section
            _buildSectionTitle('17. RTL/LTR Positioning Demo'),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Toggle RTL/LTR using the switch in the AppBar to see how dropdowns automatically adjust their positioning.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: _MyAppState.isRTL,
                      builder: (context, rtl, _) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: rtl
                                ? Colors.green.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: rtl ? Colors.green : Colors.blue,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                rtl
                                    ? Icons.format_textdirection_r_to_l
                                    : Icons.format_textdirection_l_to_r,
                                color: rtl ? Colors.green : Colors.blue,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Direction: ${rtl ? "RTL (Right-to-Left)" : "LTR (Left-to-Right)"}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: rtl
                                            ? Colors.green.shade900
                                            : Colors.blue.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      rtl
                                          ? 'Dropdowns align their RIGHT edge with anchor\'s RIGHT edge'
                                          : 'Dropdowns align their LEFT edge with anchor\'s LEFT edge',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: rtl
                                            ? Colors.green.shade700
                                            : Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Try the examples above with RTL enabled to see the positioning changes!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildRTLInfoChip(
                          '✓ LayerLink positioning',
                          'Automatically follows anchor in RTL/LTR',
                          Colors.green,
                        ),
                        _buildRTLInfoChip(
                          '✓ Rect-based positioning',
                          'Calculates correct alignment for RTL/LTR',
                          Colors.blue,
                        ),
                        _buildRTLInfoChip(
                          '✓ GlobalKey positioning',
                          'Computes Rect and applies RTL logic',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRTLInfoChip(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.black87, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 15, color: color ?? Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
