import 'package:flutter/material.dart';
import 'package:adaptive_selector/adaptive_selector.dart';

/// Example demonstrating GlobalKey-based positioning for programmatic dropdowns.
///
/// This example shows how to use the selectorKey parameter to automatically
/// compute the anchor Rect from a GlobalKey, eliminating the need to manually
/// call localToGlobal.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlobalKey Positioning Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const GlobalKeyPositioningExample(),
    );
  }
}

class GlobalKeyPositioningExample extends StatefulWidget {
  const GlobalKeyPositioningExample({super.key});

  @override
  State<GlobalKeyPositioningExample> createState() =>
      _GlobalKeyPositioningExampleState();
}

class _GlobalKeyPositioningExampleState
    extends State<GlobalKeyPositioningExample> {
  final GlobalKey _button1Key = GlobalKey();
  final GlobalKey _button2Key = GlobalKey();
  final GlobalKey _button3Key = GlobalKey();

  String? selectedColor;
  String? selectedFruit;
  String? selectedAnimal;

  final List<String> colors = ['Red', 'Green', 'Blue', 'Yellow', 'Purple'];
  final List<String> fruits = ['Apple', 'Banana', 'Cherry', 'Date'];
  final List<String> animals = ['Cat', 'Dog', 'Bird', 'Fish'];

  void _openColorDropdown() {
    AdaptiveSelector.show.dropdown<String>(
      context: context,
      options: colors,
      onChanged: (value) {
        setState(() {
          selectedColor = value;
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
      selectorKey: _button1Key, // Automatically computes Rect from key
      enableSearch: true,
      hint: 'Search colors...',
      panelWidth: 250,
    );
  }

  void _openFruitDropdown() {
    AdaptiveSelector.show.dropdown<String>(
      context: context,
      options: fruits,
      onChanged: (value) {
        setState(() {
          selectedFruit = value;
        });
      },
      itemBuilder: (context, item, isSelected) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
          ),
          child: Text(
            item,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      },
      selectorKey: _button2Key,
      panelWidth: 200,
      verticalOffset: 8,
    );
  }

  void _openAnimalDropdown() {
    AdaptiveSelector.show.dropdown<String>(
      context: context,
      options: animals,
      onChanged: (value) {
        setState(() {
          selectedAnimal = value;
        });
      },
      itemBuilder: (context, item, isSelected) {
        return ListTile(
          leading: Icon(
            _getAnimalIcon(item),
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          title: Text(item),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.blue)
              : null,
        );
      },
      selectorKey: _button3Key,
      style: const AdaptiveSelectorStyle(
        backgroundColor: Colors.white,
        borderColor: Colors.blue,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      panelWidth: 280,
    );
  }

  IconData _getAnimalIcon(String animal) {
    switch (animal) {
      case 'Cat':
        return Icons.pets;
      case 'Dog':
        return Icons.pets;
      case 'Bird':
        return Icons.flutter_dash;
      case 'Fish':
        return Icons.water;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GlobalKey Positioning Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Click buttons to open dropdowns with GlobalKey positioning:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              key: _button1Key,
              onPressed: _openColorDropdown,
              child: Text(selectedColor ?? 'Select Color'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              key: _button2Key,
              onPressed: _openFruitDropdown,
              child: Text(selectedFruit ?? 'Select Fruit'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: _button3Key,
              onPressed: _openAnimalDropdown,
              child: Text(selectedAnimal ?? 'Select Animal'),
            ),
          ],
        ),
      ),
    );
  }
}

