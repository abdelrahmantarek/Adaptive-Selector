import 'package:flutter/material.dart';
import '../models/adaptive_selector_style.dart';
import 'desktop_dropdown.dart';

/// A widget that wraps an anchor widget with LayerLink support for dropdown positioning.
///
/// This widget simplifies the use of LayerLink-based positioning by internally
/// managing the LayerLink and wrapping the child with CompositedTransformTarget.
///
/// Example:
/// ```dart
/// DropdownAnchor(
///   builder: (context, openDropdown) {
///     return ElevatedButton(
///       onPressed: () => openDropdown(
///         options: ['Option 1', 'Option 2', 'Option 3'],
///         onChanged: (value) => print(value),
///         itemBuilder: (context, item, isSelected) => Text(item),
///       ),
///       child: Text('Open Dropdown'),
///     );
///   },
/// )
/// ```
class DropdownAnchor<T> extends StatefulWidget {
  /// Builder that provides the anchor widget and a callback to open the dropdown.
  final Widget Function(
    BuildContext context,
    Future<void> Function({
      required List<T> options,
      required void Function(T) onChanged,
      required Widget Function(BuildContext, T, bool) itemBuilder,
      AdaptiveSelectorStyle style,
      bool enableSearch,
      String? hint,
      Future<List<T>> Function(String)? onSearch,
      Widget? loadingWidget,
      bool isLoading,
      Widget? headerWidget,
      Widget? footerWidget,
      List<T> selectedValues,
      ValueChanged<List<T>>? onSelectionChanged,
      bool isMultiSelect,
      Widget Function(BuildContext, void Function(T), VoidCallback)? customBuilder,
      bool autoCloseOnSelect,
      double panelWidth,
      double verticalOffset,
    }) openDropdown,
  ) builder;

  const DropdownAnchor({
    super.key,
    required this.builder,
  });

  @override
  State<DropdownAnchor<T>> createState() => _DropdownAnchorState<T>();
}

class _DropdownAnchorState<T> extends State<DropdownAnchor<T>> {
  final LayerLink _layerLink = LayerLink();

  Future<void> _openDropdown({
    required List<T> options,
    required void Function(T) onChanged,
    required Widget Function(BuildContext, T, bool) itemBuilder,
    AdaptiveSelectorStyle style = const AdaptiveSelectorStyle(),
    bool enableSearch = false,
    String? hint,
    Future<List<T>> Function(String)? onSearch,
    Widget? loadingWidget,
    bool isLoading = false,
    Widget? headerWidget,
    Widget? footerWidget,
    List<T> selectedValues = const [],
    ValueChanged<List<T>>? onSelectionChanged,
    bool isMultiSelect = false,
    Widget Function(BuildContext, void Function(T), VoidCallback)? customBuilder,
    bool autoCloseOnSelect = true,
    double panelWidth = 0,
    double verticalOffset = 5,
  }) {
    return DesktopDropdownOverlay.openOverlay<T>(
      context: context,
      style: style,
      options: options,
      selectedValue: null,
      onChanged: onChanged,
      itemBuilder: itemBuilder,
      enableSearch: enableSearch,
      hint: hint,
      onSearch: onSearch,
      loadingWidget: loadingWidget,
      isLoading: isLoading,
      headerWidget: headerWidget,
      footerWidget: footerWidget,
      selectedValues: selectedValues,
      onSelectionChanged: onSelectionChanged,
      isMultiSelect: isMultiSelect,
      customBuilder: customBuilder,
      autoCloseOnSelect: autoCloseOnSelect,
      anchorLink: _layerLink,
      panelWidth: panelWidth,
      verticalOffset: verticalOffset,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.builder(context, _openDropdown),
    );
  }
}

