# LayerLink-Based Positioning in AdaptiveSelector

## Overview

AdaptiveSelector provides multiple ways to position dropdown overlays, including robust LayerLink-based positioning that is not affected by layout changes (e.g., drawer opening/closing, RTL/LTR switching).

## Why LayerLink?

Traditional positioning using global coordinates (`Rect`) can break when:

- A drawer opens or closes
- The app switches between RTL and LTR layouts
- The screen rotates
- The keyboard appears or disappears

LayerLink solves this by creating a direct link between the anchor widget and the overlay, making the overlay follow the anchor automatically regardless of layout changes.

## RTL (Right-to-Left) Support

**All positioning approaches now fully support RTL text direction!**

The library automatically detects the current text direction using `Directionality.of(context)` and adjusts the positioning accordingly:

- **In LTR mode:** Dropdowns align their left edge with the anchor's left edge
- **In RTL mode:** Dropdowns align their right edge with the anchor's right edge

This ensures proper visual alignment in both Arabic, Hebrew, and other RTL languages, as well as standard LTR languages.

### RTL Behavior by Positioning Method

1. **LayerLink-based positioning:** Uses `Alignment.topLeft`/`Alignment.bottomLeft` in LTR mode and `Alignment.topRight`/`Alignment.bottomRight` in RTL mode for both target and follower anchors.

2. **Rect-based positioning:** Calculates the `left` position differently:

   - LTR: `left = rect.left`
   - RTL: `left = rect.right - dropdownWidth`

3. **GlobalKey-based positioning:** Automatically computes the Rect from the GlobalKey and then applies the same RTL logic as Rect-based positioning.

### Testing RTL Positioning

To test RTL positioning, wrap your app with `Directionality`:

```dart
MaterialApp(
  locale: const Locale('ar', 'EG'), // Arabic locale
  builder: (context, child) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: child!,
    );
  },
  home: MyHomePage(),
)
```

Or use the provided test app: `example/rtl_positioning_test.dart`

## Positioning Options

AdaptiveSelector supports three positioning approaches:

### 1. LayerLink (Recommended for Declarative Widgets)

**Best for:** Widgets that are part of your widget tree

**Declarative API:**

```dart
final LayerLink _anchorLink = LayerLink();

// The AdaptiveSelector automatically wraps itself with CompositedTransformTarget
AdaptiveSelector<String>(
  options: ['Option 1', 'Option 2', 'Option 3'],
  selectedValue: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
  itemBuilder: (context, item, isSelected) => Text(item),
  anchorLink: _anchorLink,
  anchorPosition: AnchorPosition.right,
  anchorOffset: Offset(8, 0),
)
```

**Programmatic API:**

```dart
final LayerLink _anchorLink = LayerLink();

// You must wrap your anchor widget with CompositedTransformTarget
CompositedTransformTarget(
  link: _anchorLink,
  child: ElevatedButton(
    onPressed: () {
      AdaptiveSelector.show.dropdown<String>(
        context: context,
        options: ['Option 1', 'Option 2', 'Option 3'],
        onChanged: (value) => print(value),
        itemBuilder: (context, item, isSelected) => Text(item),
        anchorLink: _anchorLink,
      );
    },
    child: Text('Open Dropdown'),
  ),
)
```

### 2. GlobalKey (Convenient for Programmatic API)

**Best for:** Programmatic dropdowns where you already have a GlobalKey

**Programmatic API:**

```dart
final GlobalKey _buttonKey = GlobalKey();

ElevatedButton(
  key: _buttonKey,
  onPressed: () {
    AdaptiveSelector.show.dropdown<String>(
      context: context,
      options: ['Option 1', 'Option 2', 'Option 3'],
      onChanged: (value) => print(value),
      itemBuilder: (context, item, isSelected) => Text(item),
      selectorKey: _buttonKey, // Automatically computes Rect from key
    );
  },
  child: Text('Open Dropdown'),
)
```

The library automatically computes the anchor Rect from the GlobalKey's RenderBox.

### 3. Explicit Rect (Fallback)

**Best for:** Custom positioning or when you have pre-computed coordinates

**Programmatic API:**

```dart
AdaptiveSelector.show.dropdown<String>(
  context: context,
  options: ['Option 1', 'Option 2', 'Option 3'],
  onChanged: (value) => print(value),
  itemBuilder: (context, item, isSelected) => Text(item),
  anchorRect: Rect.fromLTWH(100, 200, 200, 40),
)
```

**Note:** This approach may be affected by layout changes.

## DropdownAnchor Helper Widget

For the simplest LayerLink-based positioning, use the `DropdownAnchor` widget:

```dart
DropdownAnchor<String>(
  builder: (context, openDropdown) {
    return ElevatedButton(
      onPressed: () {
        openDropdown(
          options: ['Option 1', 'Option 2', 'Option 3'],
          onChanged: (value) => print(value),
          itemBuilder: (context, item, isSelected) => Text(item),
          enableSearch: true,
          panelWidth: 300,
        );
      },
      child: Text('Open Dropdown'),
    );
  },
)
```

The `DropdownAnchor` widget:

- Creates and manages an internal LayerLink
- Wraps your widget with CompositedTransformTarget automatically
- Provides a callback to open the dropdown with the managed LayerLink

## Comparison

| Approach           | Pros                                 | Cons                                                                  | Use Case                             |
| ------------------ | ------------------------------------ | --------------------------------------------------------------------- | ------------------------------------ |
| **LayerLink**      | Robust, follows anchor automatically | Requires manual CompositedTransformTarget wrapping (programmatic API) | Declarative widgets, complex layouts |
| **GlobalKey**      | Convenient, no manual wrapping       | Computes Rect once (not dynamic)                                      | Programmatic API, simple cases       |
| **Rect**           | Simple, explicit control             | Breaks on layout changes                                              | Static positioning, custom cases     |
| **DropdownAnchor** | Simplest, fully automatic            | Adds extra widget layer                                               | Quick prototyping, simple dropdowns  |

## Best Practices

1. **Use LayerLink for declarative widgets** - The `AdaptiveSelector` widget handles CompositedTransformTarget automatically
2. **Use GlobalKey for programmatic API** - Convenient and doesn't require manual wrapping
3. **Use DropdownAnchor for quick prototyping** - Simplest approach with automatic management
4. **Avoid Rect for dynamic layouts** - Only use when positioning is truly static

## Examples

See the following example files for complete implementations:

- `example/dropdown_anchor_example.dart` - DropdownAnchor usage
- `example/main.dart` - Various positioning approaches
