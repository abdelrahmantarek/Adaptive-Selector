import 'package:flutter/material.dart';
import 'package:adaptive_selector/adaptive_selector.dart';

/// Example demonstrating the use of DropdownAnchor for LayerLink-based positioning.
///
/// This example shows how to use the DropdownAnchor widget to create a dropdown
/// with automatic LayerLink management, eliminating the need to manually create
/// and manage LayerLinks and CompositedTransformTarget widgets.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DropdownAnchor Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const DropdownAnchorExample(),
    );
  }
}

class DropdownAnchorExample extends StatefulWidget {
  const DropdownAnchorExample({super.key});

  @override
  State<DropdownAnchorExample> createState() => _DropdownAnchorExampleState();
}

class _DropdownAnchorExampleState extends State<DropdownAnchorExample> {
  String? selectedFruit;
  final List<String> fruits = [
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
      appBar: AppBar(title: const Text('DropdownAnchor Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'Click the button to open a dropdown with LayerLink positioning:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // Example 1: Basic usage with DropdownAnchor
            DropdownAnchor<String>(
              builder: (context, openDropdown) {
                return ElevatedButton(
                  onPressed: () {
                    openDropdown(
                      options: fruits,
                      onChanged: (value) {
                        setState(() {
                          selectedFruit = value;
                        });
                      },
                      itemBuilder: (context, item, isSelected) {
                        return ListTile(
                          title: Text(item),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                        );
                      },
                      enableSearch: true,
                      hint: 'Search fruits...',
                      panelWidth: 300,
                    );
                  },
                  child: Text(selectedFruit ?? 'Select a fruit'),
                );
              },
            ),

            const SizedBox(height: 20),

            if (selectedFruit != null)
              Text(
                'Selected: $selectedFruit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            // Example 2: Custom styled dropdown
            DropdownAnchor<String>(
              builder: (context, openDropdown) {
                return OutlinedButton.icon(
                  onPressed: () {
                    openDropdown(
                      options: fruits,
                      onChanged: (value) {
                        setState(() {
                          selectedFruit = value;
                        });
                      },
                      itemBuilder: (context, item, isSelected) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withValues(alpha: 0.1)
                                : null,
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                      style: const AdaptiveSelectorStyle(
                        backgroundColor: Colors.white,
                        borderColor: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      panelWidth: 250,
                      verticalOffset: 8,
                    );
                  },
                  icon: const Icon(Icons.arrow_drop_down),
                  label: Text(selectedFruit ?? 'Choose fruit'),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
