import 'package:flutter/material.dart';

/// Style configuration for the AdaptiveSelector widget.
class AdaptiveSelectorStyle {
  /// Background color for the selector.
  final Color? backgroundColor;

  /// Text color for unselected items.
  final Color? textColor;

  /// Background color for the selected item.
  final Color? selectedItemColor;

  /// Text color for the selected item.
  final Color? selectedTextColor;

  /// Text style for items.
  final TextStyle? textStyle;

  /// Text style for the selected item.
  final TextStyle? selectedTextStyle;

  /// Icon for the dropdown arrow.
  final Icon? dropdownIcon;

  /// Icon for the search field.
  final Icon? searchIcon;

  /// Icon for the close button.
  final Icon? closeIcon;

  /// Border radius for the selector.
  final BorderRadius? borderRadius;

  /// Padding for the selector.
  final EdgeInsets? padding;

  /// Height of each item.
  final double? itemHeight;

  /// Search field decoration.
  ///
  /// Deprecated in favor of [searchFieldDecoration]. This will continue to work
  /// for backwards compatibility, but [searchFieldDecoration] takes precedence
  /// when both are provided.
  final InputDecoration? searchDecoration;

  /// Fully customizable search field decoration.
  ///
  /// If null, falls back to [searchDecoration] and then to the built-in
  /// defaults inside each widget.
  final InputDecoration? searchFieldDecoration;

  /// Divider / separator color for list items and headers.
  final Color? dividerColor;

  /// Border color for selector surfaces (trigger, panel, sheets, etc.).
  final Color? borderColor;

  /// Animation duration for dropdown animations.
  final Duration animationDuration;

  const AdaptiveSelectorStyle({
    this.backgroundColor,
    this.textColor,
    this.selectedItemColor,
    this.selectedTextColor,
    this.textStyle,
    this.selectedTextStyle,
    this.dropdownIcon,
    this.searchIcon,
    this.closeIcon,
    this.borderRadius,
    this.padding,
    this.itemHeight,
    this.searchDecoration,
    this.searchFieldDecoration,
    this.dividerColor,
    this.borderColor,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  /// Creates a copy of this style with the given fields replaced with new values.
  AdaptiveSelectorStyle copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? selectedItemColor,
    Color? selectedTextColor,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    Icon? dropdownIcon,
    Icon? searchIcon,
    Icon? closeIcon,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    double? itemHeight,
    InputDecoration? searchDecoration,
    InputDecoration? searchFieldDecoration,
    Color? dividerColor,
    Color? borderColor,
    Duration? animationDuration,
  }) {
    return AdaptiveSelectorStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      textStyle: textStyle ?? this.textStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      dropdownIcon: dropdownIcon ?? this.dropdownIcon,
      searchIcon: searchIcon ?? this.searchIcon,
      closeIcon: closeIcon ?? this.closeIcon,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      itemHeight: itemHeight ?? this.itemHeight,
      searchDecoration: searchDecoration ?? this.searchDecoration,
      searchFieldDecoration:
          searchFieldDecoration ?? this.searchFieldDecoration,
      dividerColor: dividerColor ?? this.dividerColor,
      borderColor: borderColor ?? this.borderColor,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
