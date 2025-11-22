# RTL/LTR Positioning Guide

## Overview

The AdaptiveSelector library now fully supports **RTL (Right-to-Left)** text direction, ensuring proper dropdown positioning in both Arabic, Hebrew, and other RTL languages, as well as standard LTR languages.

## How to Test RTL Support

### 1. Using the Main Example App

Run the main example app:

```bash
cd example
flutter run -d macos  # or any other device
```

**Toggle RTL/LTR:**

- Look for the **RTL/LTR switch** in the AppBar (top-right corner)
- Toggle it to switch between RTL and LTR modes
- Try any of the dropdown examples to see how they automatically adjust their positioning

### 2. Using the Dedicated RTL Test App

Run the dedicated RTL positioning test app:

```bash
cd example
flutter run -d macos -t rtl_positioning_test.dart
```

This test app provides:

- Toggle for RTL/LTR mode
- Toggle for drawer visibility (to test drawer offset scenarios)
- Test buttons for both Rect-based and LayerLink-based positioning
- Debug output showing coordinates and text direction

## RTL Positioning Behavior

### In LTR Mode (Left-to-Right)

- Dropdowns align their **left edge** with the anchor's **left edge**
- Text flows from left to right
- Example: English, Spanish, French

### In RTL Mode (Right-to-Left)

- Dropdowns align their **right edge** with the anchor's **right edge**
- Text flows from right to left
- Example: Arabic, Hebrew, Persian

## Positioning Methods

All three positioning methods support RTL:

### 1. LayerLink-based Positioning ✅

**Most Robust** - Automatically follows anchor in RTL/LTR

```dart
final LayerLink _anchorLink = LayerLink();

CompositedTransformTarget(
  link: _anchorLink,
  child: ElevatedButton(
    onPressed: () {
      AdaptiveSelector.show.dropdown<String>(
        context: context,
        anchorLink: _anchorLink,
        options: ['Option 1', 'Option 2'],
        onChanged: (value) => print(value),
        itemBuilder: (context, item, isSelected) => Text(item),
      );
    },
    child: const Text('Open Dropdown'),
  ),
)
```

### 2. GlobalKey-based Positioning ✅ **RECOMMENDED**

**Most Convenient** - Automatically handles RTL, drawer offsets, and layout changes

```dart
final GlobalKey _buttonKey = GlobalKey();

ElevatedButton(
  key: _buttonKey,
  onPressed: () {
    AdaptiveSelector.show.dropdown<String>(
      context: context,
      selectorKey: _buttonKey,  // Automatically computes Rect
      options: ['Option 1', 'Option 2'],
      onChanged: (value) => print(value),
      itemBuilder: (context, item, isSelected) => Text(item),
    );
  },
  child: const Text('Open Dropdown'),
)
```

**Why `selectorKey` is recommended:**

- ✅ No manual `localToGlobal` calculation needed
- ✅ Automatically handles RTL positioning
- ✅ Works correctly with permanent drawers
- ✅ Simplest API - just pass the GlobalKey!

### 3. Rect-based Positioning ⚠️ **NOT RECOMMENDED**

**Manual** - Requires explicit Rect calculation and can have issues with drawers/RTL

```dart
final box = context.findRenderObject() as RenderBox;
final topLeft = box.localToGlobal(Offset.zero);
final size = box.size;
final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);

AdaptiveSelector.show.dropdown<String>(
  context: context,
  anchorRect: rect,  // ⚠️ Manual Rect - can have positioning issues
  options: ['Option 1', 'Option 2'],
  onChanged: (value) => print(value),
  itemBuilder: (context, item, isSelected) => Text(item),
);
```

**Issues with `anchorRect`:**

- ❌ Requires manual `localToGlobal` calculation
- ❌ Can have positioning issues with permanent drawers
- ❌ More complex code
- ⚠️ Use `selectorKey` instead!

## Implementation Details

The library automatically detects the current text direction using:

```dart
final textDirection = Directionality.of(context);
final bool isRTL = textDirection == TextDirection.rtl;
```

Then adjusts positioning accordingly:

- **LayerLink**: Uses `Alignment.topRight`/`Alignment.bottomRight` in RTL mode
- **Rect-based**: Calculates `left = rect.right - dropdownWidth` in RTL mode
- **GlobalKey**: Computes Rect then applies RTL logic

## Examples in the Demo App

The main example app (`example/lib/main.dart`) includes:

1. **Section 17: RTL/LTR Positioning Demo** - Visual indicator showing current direction
2. All existing examples work in both RTL and LTR modes
3. Toggle switch in AppBar to test both directions

## Best Practices

1. **Use `selectorKey` for programmatic API** - Most robust, automatically handles RTL and drawer offsets
2. **Use LayerLink for declarative widgets** - Follows anchor automatically
3. **Avoid manual `anchorRect` calculation** - Using `localToGlobal` can cause issues with drawers and RTL
4. **Test both RTL and LTR** - Toggle the switch and verify positioning

## Troubleshooting

**Issue:** Dropdown appears in wrong position in RTL mode

**Solution:** Make sure you're using one of the three supported positioning methods. The library automatically handles RTL positioning.

**Issue:** Dropdown position changes when drawer opens/closes

**Solution:** Use LayerLink-based positioning instead of Rect-based positioning. LayerLink is not affected by layout changes.

## Additional Resources

- See `docs/LAYERLINK_POSITIONING.md` for comprehensive documentation
- See `example/rtl_positioning_test.dart` for a dedicated test app
- See `example/lib/main.dart` Section 17 for live examples
