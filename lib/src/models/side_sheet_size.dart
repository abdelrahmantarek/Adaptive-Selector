/// Defines the width options for side sheets (left and right).
///
/// Each size option specifies a percentage of screen width and a maximum
/// pixel width to ensure the side sheet looks good on all screen sizes.
enum SideSheetSize {
  /// Small side sheet - 60% of screen width, max 280px.
  ///
  /// Ideal for:
  /// - Compact menus
  /// - Simple selection lists
  /// - Quick actions
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: menuItems,
  ///   selectedValue: selectedMenu,
  ///   onChanged: (value) => setState(() => selectedMenu = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   mode: AdaptiveSelectorMode.leftSheet,
  ///   sideSheetSize: SideSheetSize.small,
  /// )
  /// ```
  small,

  /// Medium side sheet - 80% of screen width, max 400px (default).
  ///
  /// Ideal for:
  /// - Standard selection lists
  /// - Balanced content display
  /// - Most common use cases
  ///
  /// This is the default size if no size is specified.
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: items,
  ///   selectedValue: selectedItem,
  ///   onChanged: (value) => setState(() => selectedItem = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   mode: AdaptiveSelectorMode.rightSheet,
  ///   sideSheetSize: SideSheetSize.medium, // or omit for default
  /// )
  /// ```
  medium,

  /// Large side sheet - 90% of screen width, max 560px.
  ///
  /// Ideal for:
  /// - Detailed content
  /// - Rich item displays
  /// - Complex selection interfaces
  /// - Forms or settings panels
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: detailedItems,
  ///   selectedValue: selectedItem,
  ///   onChanged: (value) => setState(() => selectedItem = value),
  ///   itemBuilder: (context, item) => DetailedItemWidget(item),
  ///   mode: AdaptiveSelectorMode.leftSheet,
  ///   sideSheetSize: SideSheetSize.large,
  /// )
  /// ```
  large,

  /// Full-width side sheet - 100% of screen width.
  ///
  /// Ideal for:
  /// - Full-screen selection experiences
  /// - Mobile-first designs
  /// - Maximum content visibility
  /// - Immersive selection interfaces
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: products,
  ///   selectedValue: selectedProduct,
  ///   onChanged: (value) => setState(() => selectedProduct = value),
  ///   itemBuilder: (context, item) => ProductCard(item),
  ///   mode: AdaptiveSelectorMode.rightSheet,
  ///   sideSheetSize: SideSheetSize.full,
  /// )
  /// ```
  full,
}

/// Extension on [SideSheetSize] to calculate the actual width.
extension SideSheetSizeExtension on SideSheetSize {
  /// Calculates the width for this size based on the screen width.
  ///
  /// Returns a width value that respects both the percentage and maximum
  /// constraints for each size option.
  double calculateWidth(double screenWidth) {
    switch (this) {
      case SideSheetSize.small:
        // 60% of screen width, max 280px
        return (screenWidth * 0.6).clamp(0.0, 280.0);
      case SideSheetSize.medium:
        // 80% of screen width, max 400px (default)
        return (screenWidth * 0.8).clamp(0.0, 400.0);
      case SideSheetSize.large:
        // 90% of screen width, max 560px
        return (screenWidth * 0.9).clamp(0.0, 560.0);
      case SideSheetSize.full:
        // 100% of screen width (no max limit)
        return screenWidth;
    }
  }

  /// Returns a human-readable description of this size.
  String get description {
    switch (this) {
      case SideSheetSize.small:
        return 'Small (60% width, max 280px)';
      case SideSheetSize.medium:
        return 'Medium (80% width, max 400px)';
      case SideSheetSize.large:
        return 'Large (90% width, max 560px)';
      case SideSheetSize.full:
        return 'Full (100% width)';
    }
  }
}

