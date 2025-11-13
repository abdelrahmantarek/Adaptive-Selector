
import 'package:adaptive_selector/adaptive_selector.dart';
import 'package:flutter/material.dart';

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

                          await AdaptiveSelector.show.sideSheet<String>(
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

                          await AdaptiveSelector.show.sideSheet<String>(
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
