

import 'package:adaptive_selector/adaptive_selector.dart';
import 'package:flutter/material.dart';

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
