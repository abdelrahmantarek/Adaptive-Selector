import 'package:flutter/material.dart';
import 'package:adaptive_selector/adaptive_selector.dart';

/// Test app to verify RTL/LTR positioning behavior with and without drawer offset.
void main() {
  runApp(const RTLPositioningTest());
}

class RTLPositioningTest extends StatefulWidget {
  const RTLPositioningTest({super.key});

  @override
  State<RTLPositioningTest> createState() => _RTLPositioningTestState();
}

class _RTLPositioningTestState extends State<RTLPositioningTest> {
  bool isRTL = false;
  bool showDrawer = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RTL Positioning Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      builder: (context, child) {
        Widget content = child!;
        
        // Add drawer if enabled
        if (showDrawer) {
          content = Row(
            children: [
              Container(
                width: 300,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Text('Drawer (300px)'),
                ),
              ),
              Expanded(child: content),
            ],
          );
        }
        
        // Apply text direction
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: content,
        );
      },
      home: RTLTestPage(
        isRTL: isRTL,
        showDrawer: showDrawer,
        onToggleRTL: () => setState(() => isRTL = !isRTL),
        onToggleDrawer: () => setState(() => showDrawer = !showDrawer),
      ),
    );
  }
}

class RTLTestPage extends StatefulWidget {
  final bool isRTL;
  final bool showDrawer;
  final VoidCallback onToggleRTL;
  final VoidCallback onToggleDrawer;

  const RTLTestPage({
    super.key,
    required this.isRTL,
    required this.showDrawer,
    required this.onToggleRTL,
    required this.onToggleDrawer,
  });

  @override
  State<RTLTestPage> createState() => _RTLTestPageState();
}

class _RTLTestPageState extends State<RTLTestPage> {
  final GlobalKey _rectButtonKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  String? selectedFruit;

  final List<String> fruits = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];

  void _openDropdownWithRect() {
    final box = _rectButtonKey.currentContext!.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero);
    final size = box.size;
    final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);

    debugPrint('Button position: topLeft=$topLeft, size=$size');
    debugPrint('Rect: $rect');
    debugPrint('Text direction: ${widget.isRTL ? "RTL" : "LTR"}');
    debugPrint('Drawer visible: ${widget.showDrawer}');

    AdaptiveSelector.show.dropdown<String>(
      context: context,
      options: fruits,
      onChanged: (value) => setState(() => selectedFruit = value),
      itemBuilder: (context, item, isSelected) => ListTile(
        title: Text(item),
        trailing: isSelected ? const Icon(Icons.check) : null,
      ),
      anchorRect: rect,
      panelWidth: 250,
    );
  }

  void _openDropdownWithLayerLink() {
    AdaptiveSelector.show.dropdown<String>(
      context: context,
      options: fruits,
      onChanged: (value) => setState(() => selectedFruit = value),
      itemBuilder: (context, item, isSelected) => ListTile(
        title: Text(item),
        trailing: isSelected ? const Icon(Icons.check) : null,
      ),
      anchorLink: _layerLink,
      panelWidth: 250,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RTL Positioning Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Controls',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('RTL Mode'),
                      subtitle: Text('Current: ${widget.isRTL ? "RTL" : "LTR"}'),
                      value: widget.isRTL,
                      onChanged: (_) => widget.onToggleRTL(),
                    ),
                    SwitchListTile(
                      title: const Text('Show Drawer (300px)'),
                      subtitle: const Text('Simulates permanent sidebar'),
                      value: widget.showDrawer,
                      onChanged: (_) => widget.onToggleDrawer(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Test buttons
            const Text(
              'Test Dropdown Positioning:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              key: _rectButtonKey,
              onPressed: _openDropdownWithRect,
              child: const Text('Open with Rect (GlobalKey)'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Uses anchorRect computed from GlobalKey',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            
            const SizedBox(height: 24),
            
            CompositedTransformTarget(
              link: _layerLink,
              child: ElevatedButton(
                onPressed: _openDropdownWithLayerLink,
                child: const Text('Open with LayerLink'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Uses LayerLink (robust to layout changes)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            
            const SizedBox(height: 24),
            
            if (selectedFruit != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Selected: $selectedFruit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

