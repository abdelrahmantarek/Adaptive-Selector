import 'package:flutter/material.dart';
import 'package:adaptive_selector/adaptive_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Selector Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
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
              itemBuilder: (context, item) => Text(item),
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
              itemBuilder: (context, item) => Text(item),
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
              itemBuilder: (context, item) => Text('Number $item'),
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
              itemBuilder: (context, item) => Row(
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
              itemBuilder: (context, item) => Text(item),
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
              itemBuilder: (context, item) => Text(item),
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
              itemBuilder: (context, item) => Text(item),
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
              itemBuilder: (context, item) => Text(item),
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
              itemBuilder: (context, item) => Text(item),
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
              itemBuilder: (context, item) => Text(item),
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
              itemBuilder: (context, item) => Text(item),
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
              itemBuilder: (context, item) => Padding(
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
              itemBuilder: (context, item) => Text(item),
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
              itemBuilder: (context, item) => Text(item),
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
                                itemBuilder: (context, item) => Text(item),
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
                            itemBuilder: (context, item) => Text(item),
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
                            itemBuilder: (context, item) => Text(item),
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
                      itemBuilder: (context, item) => Text(item),
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
                      itemBuilder: (context, item) => Text(item),
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
          ],
        ),
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
}

/// Example page demonstrating push behavior for side sheets
class PushBehaviorExample extends StatefulWidget {
  const PushBehaviorExample({super.key});

  @override
  State<PushBehaviorExample> createState() => _PushBehaviorExampleState();
}

class _PushBehaviorExampleState extends State<PushBehaviorExample> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedLeftItem;
  String? selectedRightItem;

  final List<String> items = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Push Behavior Example'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      // Left drawer content (always available for push behavior)
      drawer: Drawer(child: _buildDrawerContent(isLeft: true)),
      // Right drawer content (always available for push behavior)
      endDrawer: Drawer(child: _buildDrawerContent(isLeft: false)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.swipe, size: 64, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                'Push Behavior Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Click the buttons below to open side sheets that push the main content aside.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Left side sheet button
              SizedBox(
                width: double.infinity,
                child: AdaptiveSelector<String>.sideSheet(
                  isLeft: true,
                  options: items,
                  selectedValue: selectedLeftItem,
                  onChanged: (value) {
                    setState(() {
                      selectedLeftItem = value;
                    });
                  },
                  itemBuilder: (context, item) => Text(item),
                  hint: 'Open Left Side Sheet (Push)',
                  usePushBehavior: true,
                  scaffoldKey: _scaffoldKey,
                  sideSheetSize: SideSheetSize.medium,
                  enableSearch: true,
                ),
              ),
              const SizedBox(height: 16),

              // Right side sheet button
              SizedBox(
                width: double.infinity,
                child: AdaptiveSelector<String>.sideSheet(
                  isLeft: false,
                  options: items,
                  selectedValue: selectedRightItem,
                  onChanged: (value) {
                    setState(() {
                      selectedRightItem = value;
                    });
                  },
                  itemBuilder: (context, item) => Text(item),
                  hint: 'Open Right Side Sheet (Push)',
                  usePushBehavior: true,
                  scaffoldKey: _scaffoldKey,
                  sideSheetSize: SideSheetSize.medium,
                  enableSearch: true,
                ),
              ),
              const SizedBox(height: 32),

              if (selectedLeftItem != null || selectedRightItem != null) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Selected Values:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (selectedLeftItem != null)
                  Text(
                    'Left: $selectedLeftItem',
                    style: const TextStyle(color: Colors.blue),
                  ),
                if (selectedRightItem != null)
                  Text(
                    'Right: $selectedRightItem',
                    style: const TextStyle(color: Colors.blue),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerContent({required bool isLeft}) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.deepPurple,
              child: Row(
                children: [
                  Icon(
                    isLeft ? Icons.arrow_back : Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLeft ? 'Left Side Sheet' : 'Right Side Sheet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  final isSelected =
                      item == (isLeft ? selectedLeftItem : selectedRightItem);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isLeft) {
                          selectedLeftItem = item;
                        } else {
                          selectedRightItem = item;
                        }
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: isSelected ? Colors.blue.shade50 : null,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.blue : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example page demonstrating contextual push for overlay side sheets
class ContextualPushExample extends StatefulWidget {
  const ContextualPushExample({super.key});

  @override
  State<ContextualPushExample> createState() => _ContextualPushExampleState();
}

class _ContextualPushExampleState extends State<ContextualPushExample> {
  double _pushPx = 0;
  final ValueNotifier<double> _pivotY = ValueNotifier(
    0.5,
  ); // 0.0 top -> 1.0 bottom (used for rotation alignment)

  final ValueNotifier<double> _pivotX = ValueNotifier(
    0.5,
  ); // 0.0 left -> 1.0 right

  // Key to measure the trigger button for precise edge-aligned push
  final GlobalKey _leftTriggerKey = GlobalKey();
  final GlobalKey _leftCustomKey = GlobalKey();

  String? selectedLeftItem;
  String? selectedRightItem;

  final List<String> items = const [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew',
  ];

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contextual Push Example'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<double>(
        valueListenable: _pivotY,
        builder: (context, pivot, _) {
          // Compute dxFraction directly from pixel offset so the library-provided
          // visibility guarantee (keeping the trigger outside the sheet) is preserved.
          final dxFraction = screenW > 0 ? (_pushPx / screenW) : 0.0;

          // Flip pivot so the area near the trigger moves more (top trigger => top moves more)
          final alignment = Alignment(
            0,
            (1 - pivot) * 2 - 1,
          ); // -1 top, 0 center, 1 bottom
          final angleTurns =
              dxFraction *
              0.02; // subtle rotation proportional to horizontal shift

          return AnimatedRotation(
            alignment: alignment,
            turns: angleTurns,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: AnimatedSlide(
              offset: Offset(dxFraction, 0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.layers,
                        size: 64,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Contextual Push (Overlay)',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Open a side sheet as an overlay while the page contents subtly shift with a hinge around the trigger\'s vertical position.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      // Left side sheet (overlay) with contextual push
                      SizedBox(
                        width: double.infinity,
                        child: AdaptiveSelector<String>.sideSheet(
                          isLeft: true,
                          options: items,
                          selectedValue: selectedLeftItem,
                          onChanged: (value) {
                            setState(() => selectedLeftItem = value);
                          },
                          itemBuilder: (context, item) => Text(item),
                          hint:
                              'Open Left Side Sheet (Overlay + Contextual Push)',
                          useContextualPush: true,
                          maxContextualPushOffset: 0.0,
                          onContextualPushOffsetChanged: (v) =>
                              setState(() => _pushPx = v),
                          onContextualPushPivotYChanged: (v) =>
                              _pivotY.value = v,
                          onContextualPushPivotXChanged: (v) =>
                              _pivotX.value = v,
                          enableSearch: true,
                          footerWidget: Text("ssss"),
                        ),
                      ),

                      ElevatedButton(
                        key: _leftTriggerKey,
                        onPressed: () async {
                          final ctx = _leftTriggerKey.currentContext;
                          final ro = ctx?.findRenderObject();
                          if (ro is! RenderBox) return;
                          final topLeft = ro.localToGlobal(Offset.zero);
                          final size = ro.size;
                          final triggerPos = Offset(
                            topLeft.dx,
                            topLeft.dy + size.height / 2,
                          );

                          await AdaptiveSelector.openSideSheetOverlay<String>(
                            context: context,
                            isLeftSide: true,
                            size: SideSheetSize.medium,
                            style: const AdaptiveSelectorStyle(),
                            options: items,
                            selectedValue: selectedLeftItem,

                            enableSearch: true,
                            // Edge-aligned contextual push driven by the trigger button
                            useContextualPush: true,
                            triggerPosition: triggerPos,
                            maxContextualPushOffset: 0.0,
                            onContextualPushOffsetChanged: (v) =>
                                setState(() => _pushPx = v),
                            onContextualPushPivotYChanged: (v) =>
                                _pivotY.value = v,
                            onContextualPushPivotXChanged: (v) =>
                                _pivotX.value = v,
                            footerWidget: Text("footerWidget"),
                            headerWidget: Text("headerWidget"),
                          );
                        },
                        child: Text(
                          "Open Left Side Sheet (Overlay + Contextual Push)",
                        ),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        key: _leftCustomKey,
                        onPressed: () async {
                          final ctx = _leftCustomKey.currentContext;
                          final ro = ctx?.findRenderObject();
                          if (ro is! RenderBox) return;
                          final topLeft = ro.localToGlobal(Offset.zero);
                          final size = ro.size;
                          final triggerPos = Offset(
                            topLeft.dx,
                            topLeft.dy + size.height / 2,
                          );

                          await AdaptiveSelector.openSideSheetOverlay<String>(
                            context: context,
                            isLeftSide: true,
                            size: SideSheetSize.medium,
                            style: const AdaptiveSelectorStyle(),
                            // Fully custom content replaces default list UI
                            customBuilder: (ctx, select, close) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Custom Header',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: close,
                                          icon: const Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  Expanded(
                                    child: ListView(
                                      children: [
                                        ListTile(
                                          title: const Text('Option A'),
                                          onTap: () => select('Option A'),
                                        ),
                                        ListTile(
                                          title: const Text('Option B'),
                                          onTap: () => select('Option B'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: ElevatedButton(
                                            onPressed: close,
                                            child: const Text('Close'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text('Custom Footer'),
                                  ),
                                ],
                              );
                            },
                            // Edge-aligned contextual push driven by the custom trigger button
                            useContextualPush: true,
                            triggerPosition: triggerPos,
                            maxContextualPushOffset: 0.0,
                            onContextualPushOffsetChanged: (v) =>
                                setState(() => _pushPx = v),
                            onContextualPushPivotYChanged: (v) =>
                                _pivotY.value = v,
                            onContextualPushPivotXChanged: (v) =>
                                _pivotX.value = v,
                            // Ensure select() updates the demo state
                            onChanged: (v) =>
                                setState(() => selectedLeftItem = v),
                          );
                        },
                        child: const Text(
                          'Open Left Side Sheet (Custom Content + Contextual Push)',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Right side sheet (overlay) with contextual push
                      SizedBox(
                        width: double.infinity,
                        child: AdaptiveSelector<String>.sideSheet(
                          isLeft: false,
                          options: items,
                          selectedValue: selectedRightItem,
                          onChanged: (value) {
                            setState(() => selectedRightItem = value);
                          },
                          itemBuilder: (context, item) => Text(item),
                          hint:
                              'Open Right Side Sheet (Overlay + Contextual Push)',
                          useContextualPush: true,
                          maxContextualPushOffset: 24.0,
                          onContextualPushOffsetChanged: (v) =>
                              setState(() => _pushPx = v),
                          onContextualPushPivotYChanged: (v) =>
                              _pivotY.value = v,
                          onContextualPushPivotXChanged: (v) =>
                              _pivotX.value = v,
                          enableSearch: true,
                        ),
                      ),

                      const SizedBox(height: 32),
                      if (selectedLeftItem != null ||
                          selectedRightItem != null) ...[
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'Selected Values:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (selectedLeftItem != null)
                          Text(
                            'Left: $selectedLeftItem',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        if (selectedRightItem != null)
                          Text(
                            'Right: $selectedRightItem',
                            style: const TextStyle(color: Colors.blue),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pivotY.dispose();
    _pivotX.dispose();
    super.dispose();
  }
}
