## AdaptiveSelector

A single, adaptive selection component for Flutter that renders as a dropdown, bottom sheet, left/right side sheet, or anchored panel — automatically or explicitly — with both declarative constructors and a programmatic overlay API.

- Declarative: AdaptiveSelector(), .sideSheet(), .bottomSheet(), .dropdown()
- Programmatic overlays: AdaptiveSelector.show.dropdown(), .show.sideSheet(), .show.bottomSheet(), .show.dropdownOrSheet()
- Features: search (sync/async), customBuilder override, header/footer widgets, SafeArea control, push/contextual push for side sheets, anchored panels, and more

### Install

Add to pubspec.yaml:

```yaml
dependencies:
  adaptive_selector: ^0.1.0
```

Import:

```dart
import 'package:adaptive_selector/adaptive_selector.dart';
```

---

## Table of Contents

- [Common setup used in snippets](#common-setup-used-in-snippets)
- [1. Basic Selector](#1-basic-selector)
- [2. Selector with Synchronous Search](#2-selector-with-synchronous-search)
- [3. Custom Styled Selector with Animations](#3-custom-styled-selector-with-animations)
- [4. Asynchronous Search (Simulated API)](#4-asynchronous-search-simulated-api)
- [5. Force Mobile UI (Always Bottom Sheet)](#5-force-mobile-ui-always-bottom-sheet)
- [6. Force Desktop UI (Always Dropdown)](#6-force-desktop-ui-always-dropdown)
- [7. Left Side Sheet](#7-left-side-sheet)
- [8. Right Side Sheet](#8-right-side-sheet)
- [9. Small Side Sheet (Compact)](#9-small-side-sheet-compact)
- [10. Large Side Sheet (Detailed)](#10-large-side-sheet-detailed)
- [11. Full-Width Side Sheet](#11-full-width-side-sheet)
- [12. Advanced: All Features Combined](#12-advanced-all-features-combined)
- [13. SafeArea: Enabled (Default)](#13-safearea-enabled-default)
- [14. SafeArea: Disabled (Full Bleed)](#14-safearea-disabled-full-bleed)
- [15. Anchored Panel Mode](#15-anchored-panel-mode)
- [16. Named Constructors API](#16-named-constructors-api)
- [17. Push Behavior for Side Sheets](#17-push-behavior-for-side-sheets)
- [18. Contextual Push Animation (Overlay)](#18-contextual-push-animation-overlay)
- [19. Programmatic API: show.dropdown (customBuilder)](#19-programmatic-api-showdropdown-custombuilder)
- [20. Programmatic API: show.dropdownOrSheet](#20-programmatic-api-showdropdownorsheet)
- [21. Programmatic API: Closing behavior (autoCloseOnSelect)](#21-programmatic-api-closing-behavior-autocloseonselect)

---

## Common setup used in snippets

To keep each example concise, the following shared setup (lists and simple state) is assumed. Paste this once, then paste any section snippet into the build method or callbacks.

```dart
import 'package:flutter/material.dart';
import 'package:adaptive_selector/adaptive_selector.dart';

final fruits = [
  'Apple','Banana','Cherry','Date','Elderberry','Fig','Grape','Honeydew'
];
final countries = [
  'United States','Canada','Brazil','United Kingdom','Germany','France','Japan','Australia','India','China'
];
final numbers = List<int>.generate(10, (i) => i + 1);
final timeSlots = [
  '09:00 AM','09:30 AM','10:00 AM','10:30 AM','11:00 AM','11:30 AM','12:00 PM','12:30 PM'
];

class ExampleHost extends StatefulWidget {
  final Widget Function(BuildContext, void Function(VoidCallback)) builder;
  const ExampleHost({super.key, required this.builder});
  @override State<ExampleHost> createState() => _ExampleHostState();
}
class _ExampleHostState extends State<ExampleHost> {
  @override Widget build(BuildContext context) => widget.builder(context, (fn){ setState(fn); });
}
```

Tip: Use ExampleHost(builder: ...) to get setState access for snippets.

---

## 1. Basic Selector

Simple selector without search.

```dart
AdaptiveSelector<String>(
  options: fruits,
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'Select a fruit',
)
```

## 2. Selector with Synchronous Search

Search filters options locally.

```dart
AdaptiveSelector<String>(
  options: countries,
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'Select a country',
  enableSearch: true,
)
```

## 3. Custom Styled Selector with Animations

Shows styling and animation controls.

```dart
AdaptiveSelector<int>(
  options: numbers,
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text('Number $item'),
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
)
```

## 4. Asynchronous Search (Simulated API)

Async search with loading states and header/footer widgets.

```dart
Future<List<String>> onSearch(String q) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return countries.where((c) => c.toLowerCase().contains(q.toLowerCase())).toList();
}
AdaptiveSelector<String>(
  options: const [],
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Row(children:[const Icon(Icons.cloud,size:16,color:Colors.blue),const SizedBox(width:8),Text(item)]),
  hint: 'Search remote data...',
  enableSearch: true,
  onSearch: onSearch,
  dropdownHeaderWidget: const Padding(padding: EdgeInsets.all(8), child: Text('Remote Data Source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
  dropdownFooterWidget: const Padding(padding: EdgeInsets.all(8), child: Text('Results', style: TextStyle(fontSize: 11, color: Colors.grey))),
)
```

## 5. Force Mobile UI (Always Bottom Sheet)

Always uses bottom sheet.

```dart
AdaptiveSelector<String>(
  options: fruits,
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'Always shows bottom sheet',
  mode: AdaptiveSelectorMode.alwaysMobile,
)
```

## 6. Force Desktop UI (Always Dropdown)

Always uses dropdown overlay.

```dart
AdaptiveSelector<String>(
  options: countries,
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'Always shows dropdown',
  mode: AdaptiveSelectorMode.alwaysDesktop,
  enableSearch: true,
)
```

## 7. Left Side Sheet

Drawer-style left sheet.

```dart
AdaptiveSelector<String>(
  options: fruits.take(8).toList(),
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'Select from left sheet',
  mode: AdaptiveSelectorMode.leftSheet,
  enableSearch: true,
)
```

## 8. Right Side Sheet

Settings-style right sheet.

```dart
AdaptiveSelector<String>(
  options: countries.take(8).toList(),
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'Select from right sheet',
  mode: AdaptiveSelectorMode.rightSheet,
  enableSearch: true,
)
```

## 9. Small Side Sheet (Compact)

Small width (60%, max ~280px).

```dart
AdaptiveSelector<String>(
  options: fruits.take(6).toList(),
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'Select from small sheet',
  mode: AdaptiveSelectorMode.leftSheet,
  sideSheetSize: SideSheetSize.small,
  enableSearch: true,
)
```

## 10. Large Side Sheet (Detailed)

Large width (90%, max ~560px) + header.

```dart
AdaptiveSelector<String>(
  options: countries.take(10).toList(),
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'Select from large sheet',
  mode: AdaptiveSelectorMode.rightSheet,
  sideSheetSize: SideSheetSize.large,
  enableSearch: true,
  headerWidget: const Padding(padding: EdgeInsets.all(12), child: Text('🌍 Select Your Country', style: TextStyle(fontWeight: FontWeight.w600))),
)
```

## 11. Full-Width Side Sheet

Full width immersive sheet + footer.

```dart
AdaptiveSelector<String>(
  options: fruits,
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'Select from full sheet',
  mode: AdaptiveSelectorMode.leftSheet,
  sideSheetSize: SideSheetSize.full,
  enableSearch: true,
  footerWidget: const Padding(padding: EdgeInsets.all(12), child: Text('Full-screen selection', style: TextStyle(fontSize: 12))),
)
```

## 12. Advanced: All Features Combined

Custom size + header/footer + styling + async search.

```dart
AdaptiveSelector<String>(
  options: countries,
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Row(children:[const Icon(Icons.location_on,size:16), const SizedBox(width:8), Text(item)]),
  hint: 'Advanced selector',
  mode: AdaptiveSelectorMode.rightSheet,
  sideSheetSize: SideSheetSize.large,
  enableSearch: true,
  onSearch: (q) async => countries.where((c)=>c.toLowerCase().contains(q.toLowerCase())).toList(),
  headerWidget: const Padding(padding: EdgeInsets.all(16), child: Text('Country Selector', style: TextStyle(fontWeight: FontWeight.bold))),
  footerWidget: const Padding(padding: EdgeInsets.all(12), child: Text('Powered by async search', style: TextStyle(fontSize: 11))),
)
```

## 13. SafeArea: Enabled (Default)

Respects device safe areas (notches/status bar).

```dart
AdaptiveSelector<String>(
  options: fruits.take(5).toList(),
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'With SafeArea (default)',
  mode: AdaptiveSelectorMode.bottomSheet,
  useSafeArea: true,
)
```

## 14. SafeArea: Disabled (Full Bleed)

Extends content to screen edges.

```dart
AdaptiveSelector<String>(
  options: fruits.take(5).toList(),
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  hint: 'Without SafeArea',
  mode: AdaptiveSelectorMode.leftSheet,
  useSafeArea: false,
  sideSheetSize: SideSheetSize.medium,
)
```

## 15. Anchored Panel Mode

Position a panel next to a widget using an anchor link.

```dart
final _calendarAnchorLink = LayerLink();
// Inside a calendar/timeline cell:
AdaptiveSelector<String>(
  options: timeSlots,
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (ctx, item) => Text(item),
  anchorLink: _calendarAnchorLink,
  anchorPosition: AnchorPosition.right,
  anchorOffset: const Offset(8, 0),
  anchorPanelWidth: 250,
  enableSearch: true,
  hint: 'Select Time',
)
```

## 16. Named Constructors API

Explicit modes via constructors.

```dart
// Side sheets
AdaptiveSelector<String>.sideSheet(isLeft: true, options: fruits, selectedValue: null, onChanged: (v)=>setState((){}), itemBuilder: (c,i)=>Text(i), hint: 'Left Side Sheet', sideSheetSize: SideSheetSize.medium);
AdaptiveSelector<String>.sideSheet(isLeft: false, options: fruits, selectedValue: null, onChanged: (v)=>setState((){}), itemBuilder: (c,i)=>Text(i), hint: 'Right Side Sheet', sideSheetSize: SideSheetSize.medium);

// Bottom sheet
AdaptiveSelector<String>.bottomSheet(options: fruits, selectedValue: null, onChanged: (v)=>setState((){}), itemBuilder: (c,i)=>Text(i), hint: 'Bottom Sheet', enableSearch: true);

// Dropdown
AdaptiveSelector<String>.dropdown(options: fruits, selectedValue: null, onChanged: (v)=>setState((){}), itemBuilder: (c,i)=>Text(i), hint: 'Dropdown', enableSearch: true);
```

## 17. Push Behavior for Side Sheets

Have a side sheet push page content using Scaffold drawers.

```dart
final _scaffoldKey = GlobalKey<ScaffoldState>();
Scaffold(
  key: _scaffoldKey,
  drawer: const Drawer(child: SizedBox()),
  endDrawer: const Drawer(child: SizedBox()),
  body: Center(
    child: AdaptiveSelector<String>.sideSheet(
      isLeft: true,
      options: fruits,
      selectedValue: null,
      onChanged: (v) => setState((){}),
      itemBuilder: (c,i)=>Text(i),
      hint: 'Open Left Side Sheet (Push)',
      usePushBehavior: true,
      scaffoldKey: _scaffoldKey,
      sideSheetSize: SideSheetSize.medium,
    ),
  ),
)
```

## 18. Contextual Push Animation (Overlay)

Open a side sheet as an overlay while subtly shifting/hinging the page.

```dart
double pushPx = 0; final pivotY = ValueNotifier(0.5);
AdaptiveSelector<String>.sideSheet(
  isLeft: true,
  options: fruits,
  selectedValue: null,
  onChanged: (v) => setState((){}),
  itemBuilder: (c,i)=>Text(i),
  hint: 'Overlay + Contextual Push',
  useContextualPush: true,
  maxContextualPushOffset: 0.0,
  onContextualPushOffsetChanged: (v)=> setState(()=> pushPx = v),
  onContextualPushPivotYChanged: (v)=> pivotY.value = v,
)
```

## 19. Programmatic API: show.dropdown (customBuilder)

Open dropdown overlay programmatically anchored by LayerLink or measured Rect.

```dart
// LayerLink anchoring
final link = LayerLink();
CompositedTransformTarget(
  link: link,
  child: ElevatedButton(
    onPressed: () async {
      await AdaptiveSelector.show.dropdown<String>(
        context: context,
        anchorLink: link,
        panelWidth: 260,
        anchorHeight: 40,
        onChanged: (v) => setState((){}),
        customBuilder: (ctx, select, close) {
          final opts = fruits.take(6).toList();
          return Column(mainAxisSize: MainAxisSize.min, children: [
            const Padding(padding: EdgeInsets.all(12), child: Text('Custom Dropdown (Link)', style: TextStyle(fontWeight: FontWeight.bold))),
            const Divider(height: 1),
            Flexible(child: ListView.separated(shrinkWrap: true, itemCount: opts.length, separatorBuilder: (_, __)=>const Divider(height:1), itemBuilder: (c,i){ final it = opts[i]; return ListTile(dense:true,title:Text(it), onTap: ()=> select(it));})),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: close, child: const Text('Cancel'))),
          ]);
        },
      );
    },
    child: const Text('Open (LayerLink)'),
  ),
)

// Rect anchoring
final key = GlobalKey();
ElevatedButton(
  key: key,
  onPressed: () async {
    final box = key.currentContext!.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero); final size = box.size;
    final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);
    await AdaptiveSelector.show.dropdown<String>(
      context: context,
      anchorRect: rect,
      panelWidth: 260,
      anchorHeight: size.height,
      onChanged: (v) => setState((){}),
      customBuilder: (ctx, select, close) { /* same as above */ return const SizedBox(); },
    );
  },
  child: const Text('Open (Rect)'),
)
```

## 20. Programmatic API: show.dropdownOrSheet

Adapts between dropdown (>= breakpoint) and bottom sheet (< breakpoint). Demonstrates simple usage and advanced customBuilder. Note: anchorRect is used only in dropdown mode and ignored in bottom sheet mode.

```dart
// Simple usage (Rect anchoring)
final keySimple = GlobalKey();
ElevatedButton(
  key: keySimple,
  onPressed: () async {
    final box = keySimple.currentContext!.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero); final size = box.size;
    final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);
    await AdaptiveSelector.show.dropdownOrSheet<String>(
      context: context,
      breakpoint: 600,
      options: fruits.take(8).toList(),
      selectedValue: null,
      onChanged: (v) => setState((){}),
      itemBuilder: (ctx, item) => Text(item),
      enableSearch: true,
      hint: 'Pick a fruit...',
      headerWidget: const Padding(padding: EdgeInsets.all(8), child: Text('Select a fruit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      footerWidget: const Padding(padding: EdgeInsets.all(8), child: Text('Tap outside or press Esc to close', style: TextStyle(fontSize: 11, color: Colors.grey))),
      anchorRect: rect,
      panelWidth: 260,
      anchorHeight: size.height,
      verticalOffset: 6,
    );
  },
  child: const Text('Open dropdownOrSheet (Simple)'),
)

// Advanced (customBuilder + Rect anchoring)
final keyCustom = GlobalKey();
ElevatedButton(
  key: keyCustom,
  onPressed: () async {
    final box = keyCustom.currentContext!.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero); final size = box.size;
    final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);
    await AdaptiveSelector.show.dropdownOrSheet<String>(
      context: context,
      breakpoint: 600,
      onChanged: (v) => setState((){}),
      customBuilder: (ctx, select, close) {
        final opts = countries.take(6).toList();
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.fromLTRB(12,12,8,8), child: Row(children:[const Expanded(child: Text('Custom content', style: TextStyle(fontWeight: FontWeight.bold))), IconButton(tooltip: 'Close', onPressed: close, icon: const Icon(Icons.close))])),
          const Divider(height: 1),
          Flexible(child: ListView.separated(shrinkWrap: true, itemCount: opts.length, separatorBuilder: (_, __)=>const Divider(height:1), itemBuilder: (c,i){ final e = opts[i]; return ListTile(dense:true, title: Text(e), onTap: ()=> select(e)); })),
        ]);
      },
      anchorRect: rect,
      panelWidth: 320,
      anchorHeight: size.height,
      verticalOffset: 6,
    );
  },
  child: const Text('Open dropdownOrSheet (Custom)'),
)

```

## 21. Programmatic API: Closing behavior (autoCloseOnSelect)

- select(value) always calls onChanged(value) when provided
- By default, select(value) auto-closes the opened overlay/sheet across all show.\* APIs when using customBuilder
- To keep it open after selecting, pass autoCloseOnSelect: false
- close() always closes exactly what was opened by the API (Overlay/ModalBottomSheet/SideSheet)
- Note: In bottom sheet list-mode (non-customBuilder), tapping an item closes the sheet by design

```dart
// Small-screen friendly: dropdownOrSheet + customBuilder + keep-open
final keySmall = GlobalKey();
ElevatedButton(
  key: keySmall,
  onPressed: () async {
    final box = keySmall.currentContext!.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero); final size = box.size;
    final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);

    await AdaptiveSelector.show.dropdownOrSheet<String>(
      context: context,
      breakpoint: 600, // <600 => BottomSheet, >=600 => Dropdown
      autoCloseOnSelect: false, // keep open after select(...)
      onChanged: (v) => setState(() {}),
      customBuilder: (ctx, select, close) {
        final opts = fruits.take(5).toList();
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(children: [
              const Expanded(child: Text('Pick & stay open')),
              IconButton(onPressed: close, icon: const Icon(Icons.close)),
            ]),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: opts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (c, i) {
                final it = opts[i];
                return ListTile(
                  dense: true,
                  title: Text(it),
                  onTap: () => select(it), // stays open
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: close, child: const Text('Close')),
          ),
        ]);
      },
      // Anchor is used only in dropdown mode
      anchorRect: rect,
      panelWidth: 280,
      anchorHeight: size.height,
      verticalOffset: 6,
    );
  },
  child: const Text('Open (closing behavior)'),
)
```

---

Notes

- customBuilder signature: (BuildContext, void Function(T) select, VoidCallback close)
- All programmatic show.\* APIs are overlay-based
- dropdownOrSheet breakpoint: uses dropdown when width >= breakpoint; otherwise bottom sheet
- Closing behavior (customBuilder): select(value) auto-closes by default; pass autoCloseOnSelect: false to keep the panel open
- close() always closes what was opened internally (Overlay/ModalBottomSheet/SideSheet); you do not need to call Navigator.pop
- BottomSheet list-mode: tapping an item always closes the sheet (autoCloseOnSelect applies to customBuilder path)

- Anchoring: dropdown/show APIs support both LayerLink (anchorLink) and Rect (anchorRect)
- SafeArea can be enabled/disabled per mode; default is enabled for bottom sheets

For full runnable examples, see example/lib/main.dart in this repo.
