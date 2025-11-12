/// Defines the preferred positioning for anchored panels.
///
/// When using anchored panel mode, this enum specifies where the panel
/// should appear relative to the anchor widget.
///
/// The panel will automatically adjust its position if there's not enough
/// space in the preferred direction (e.g., flip from right to left if near
/// the screen edge).
enum AnchorPosition {
  /// Automatically determine the best position based on available space.
  ///
  /// The panel will analyze the anchor widget's position on screen and
  /// choose the position with the most available space.
  ///
  /// Priority order: right → left → bottom → top
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: items,
  ///   selectedValue: selected,
  ///   onChanged: (value) => setState(() => selected = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   anchorLink: _anchorLink,
  ///   anchorPosition: AnchorPosition.auto, // Default
  /// )
  /// ```
  auto,

  /// Position the panel to the right of the anchor widget.
  ///
  /// If there's not enough space on the right, it will flip to the left.
  ///
  /// Ideal for:
  /// - Left-aligned navigation items
  /// - Timeline events on the left side
  /// - Left sidebar items
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: items,
  ///   selectedValue: selected,
  ///   onChanged: (value) => setState(() => selected = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   anchorLink: _anchorLink,
  ///   anchorPosition: AnchorPosition.right,
  /// )
  /// ```
  right,

  /// Position the panel to the left of the anchor widget.
  ///
  /// If there's not enough space on the left, it will flip to the right.
  ///
  /// Ideal for:
  /// - Right-aligned navigation items
  /// - Timeline events on the right side
  /// - Right sidebar items
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: items,
  ///   selectedValue: selected,
  ///   onChanged: (value) => setState(() => selected = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   anchorLink: _anchorLink,
  ///   anchorPosition: AnchorPosition.left,
  /// )
  /// ```
  left,

  /// Position the panel below the anchor widget.
  ///
  /// If there's not enough space below, it will flip to above.
  ///
  /// Ideal for:
  /// - Toolbar buttons
  /// - Header menu items
  /// - Top navigation elements
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: items,
  ///   selectedValue: selected,
  ///   onChanged: (value) => setState(() => selected = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   anchorLink: _anchorLink,
  ///   anchorPosition: AnchorPosition.bottom,
  /// )
  /// ```
  bottom,

  /// Position the panel above the anchor widget.
  ///
  /// If there's not enough space above, it will flip to below.
  ///
  /// Ideal for:
  /// - Bottom toolbar buttons
  /// - Footer menu items
  /// - Bottom navigation elements
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: items,
  ///   selectedValue: selected,
  ///   onChanged: (value) => setState(() => selected = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   anchorLink: _anchorLink,
  ///   anchorPosition: AnchorPosition.top,
  /// )
  /// ```
  top,
}

/// Extension methods for [AnchorPosition].
extension AnchorPositionExtension on AnchorPosition {
  /// Returns a human-readable description of the anchor position.
  String get description {
    switch (this) {
      case AnchorPosition.auto:
        return 'Auto (best available space)';
      case AnchorPosition.right:
        return 'Right of anchor';
      case AnchorPosition.left:
        return 'Left of anchor';
      case AnchorPosition.bottom:
        return 'Below anchor';
      case AnchorPosition.top:
        return 'Above anchor';
    }
  }

  /// Returns the opposite position (used for flipping when there's not enough space).
  AnchorPosition get opposite {
    switch (this) {
      case AnchorPosition.right:
        return AnchorPosition.left;
      case AnchorPosition.left:
        return AnchorPosition.right;
      case AnchorPosition.bottom:
        return AnchorPosition.top;
      case AnchorPosition.top:
        return AnchorPosition.bottom;
      case AnchorPosition.auto:
        return AnchorPosition.auto; // Auto doesn't have an opposite
    }
  }

  /// Returns true if this is a horizontal position (left or right).
  bool get isHorizontal {
    return this == AnchorPosition.left || this == AnchorPosition.right;
  }

  /// Returns true if this is a vertical position (top or bottom).
  bool get isVertical {
    return this == AnchorPosition.top || this == AnchorPosition.bottom;
  }
}

