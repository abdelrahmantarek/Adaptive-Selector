import 'package:flutter/material.dart';

// Export public API
export 'src/models/adaptive_selector_style.dart';
export 'src/models/adaptive_selector_mode.dart';
export 'src/models/side_sheet_size.dart';
export 'src/models/anchor_position.dart';
export 'src/widgets/loading_widget.dart';
export 'src/widgets/dropdown_anchor.dart';

// Internal imports
import 'src/models/adaptive_selector_style.dart';
import 'src/models/adaptive_selector_mode.dart';
import 'src/models/side_sheet_size.dart';
import 'src/models/anchor_position.dart';
import 'src/widgets/desktop_dropdown.dart';
import 'src/widgets/mobile_bottom_sheet.dart';
import 'src/widgets/side_sheet.dart';
import 'src/widgets/anchored_panel.dart';

/// A widget that adapts its UI based on device type and screen size.
///
/// On small screens (width < 600px), it displays options in a BottomSheet.
/// On large screens (width >= 600px), it displays options in a Dropdown menu.
///
/// Supports both synchronous and asynchronous search functionality.
///
/// Example (Synchronous):
/// ```dart
/// AdaptiveSelector<String>(
///   options: ['Option 1', 'Option 2', 'Option 3'],
///   selectedValue: selectedOption,
///   onChanged: (value) => setState(() => selectedOption = value),
///   itemBuilder: (context, item) => Text(item),
///   enableSearch: true,
/// )
/// ```
///
/// Example (Asynchronous with remote search):
/// ```dart
/// AdaptiveSelector<User>(
///   options: users,
///   selectedValue: selectedUser,
///   onChanged: (value) => setState(() => selectedUser = value),
///   itemBuilder: (context, user) => Text(user.name),
///   enableSearch: true,
///   onSearch: (query) async {
///     // Fetch from API
///     final response = await api.searchUsers(query);
///     return response.users;
///   },
///   loadingWidget: CustomLoadingWidget(),
/// )
/// ```
class AdaptiveSelector<T> extends StatefulWidget {
  /// The list of selectable items.
  /// For async search, this can be an empty list initially.
  final List<T> options;

  /// The currently selected value.
  final T? selectedValue;

  /// The currently selected values for multi-select mode. Empty when single-select.
  final List<T> selectedValues;

  /// Callback when the multi-selection list changes. Null in single-select.
  final ValueChanged<List<T>>? onSelectionChanged;

  /// Optional builder for how to render the selected values in the trigger when multi-select.
  final Widget Function(BuildContext, List<T>)? selectedValuesBuilder;

  /// Whether the selector operates in multi-select mode.
  final bool isMultiSelect;

  /// Callback function that triggers when user selects an option.
  final void Function(T value) onChanged;

  /// Function to build the display representation of each option.
  /// The third parameter (bool isSelected) indicates whether the item is currently selected.
  final Widget Function(BuildContext context, T item, bool isSelected)
  itemBuilder;

  /// Whether to enable search functionality. Default is false.
  final bool enableSearch;

  /// Custom styling for the selector.
  final AdaptiveSelectorStyle? style;

  /// Hint text to display when no value is selected.
  final String? hint;

  /// The breakpoint width (in pixels) to determine small vs large screens.
  /// Default is 600.
  final double breakpoint;

  /// Optional asynchronous search callback.
  /// When provided, search will be performed asynchronously.
  /// The function receives the search query and should return a `Future<List<T>>`.
  ///
  /// Example:
  /// ```dart
  /// onSearch: (query) async {
  ///   final results = await apiService.search(query);
  ///   return results;
  /// }
  /// ```
  final Future<List<T>> Function(String query)? onSearch;

  /// Custom loading widget to display during async operations.
  /// If not provided, a default CircularProgressIndicator will be used.
  final Widget? loadingWidget;

  /// Whether the selector is currently loading initial data.
  /// Set this to true when fetching initial options asynchronously.
  final bool isLoading;

  /// Optional custom widget to display at the top of the desktop dropdown.
  /// Only applies to large screens (desktop mode).
  /// Can be used for headers, filters, or any custom content.
  final Widget? dropdownHeaderWidget;

  /// Optional custom widget to display at the bottom of the desktop dropdown.
  /// Only applies to large screens (desktop mode).
  /// Can be used for footers, action buttons, or any custom content.
  final Widget? dropdownFooterWidget;

  /// Whether the desktop dropdown should automatically close when an item is
  /// selected.
  ///
  /// Only applies when using dropdown / alwaysDesktop modes. Ignored for
  /// bottom sheets and side sheets. Defaults to true.
  final bool autoCloseWhenSelect;

  /// The UI mode for the selector.
  ///
  /// Controls whether the selector should automatically adapt based on screen
  /// size, or force a specific UI mode regardless of screen size.
  ///
  /// - [AdaptiveSelectorMode.automatic] (default): Automatically switch between
  ///   mobile and desktop UI based on screen size and breakpoint.
  /// - [AdaptiveSelectorMode.alwaysMobile]: Always use mobile UI (bottom sheet)
  ///   regardless of screen size.
  /// - [AdaptiveSelectorMode.alwaysDesktop]: Always use desktop UI (dropdown)
  ///   regardless of screen size.
  final AdaptiveSelectorMode mode;

  /// The width size for side sheets (left and right).
  ///
  /// Controls the width of the side sheet when using [AdaptiveSelectorMode.leftSheet]
  /// or [AdaptiveSelectorMode.rightSheet] modes.
  ///
  /// Available sizes:
  /// - [SideSheetSize.small]: 60% of screen width, max 280px
  /// - [SideSheetSize.medium]: 80% of screen width, max 400px (default)
  /// - [SideSheetSize.large]: 90% of screen width, max 560px
  /// - [SideSheetSize.full]: 100% of screen width
  ///
  /// This parameter is ignored when using other modes (automatic, bottomSheet, dropdown).
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: items,
  ///   selectedValue: selectedItem,
  ///   onChanged: (value) => setState(() => selectedItem = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   mode: AdaptiveSelectorMode.leftSheet,
  ///   sideSheetSize: SideSheetSize.large,
  /// )
  /// ```
  final SideSheetSize sideSheetSize;

  /// Whether to wrap the selector UI in a SafeArea widget.
  ///
  /// When `true` (default), the selector content will respect device safe area
  /// insets (notches, status bars, home indicators, etc.) to avoid overlapping
  /// with system UI elements.
  ///
  /// When `false`, the content will extend to the screen edges (full bleed),
  /// which may overlap with system UI on devices with notches or rounded corners.
  ///
  /// This applies to:
  /// - Mobile bottom sheets
  /// - Side sheets (left and right)
  /// - Desktop dropdown (typically doesn't need SafeArea)
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: items,
  ///   selectedValue: selectedItem,
  ///   onChanged: (value) => setState(() => selectedItem = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   useSafeArea: true, // Respect device safe areas
  /// )
  /// ```
  final bool useSafeArea;

  /// Whether to use push behavior for side sheets.
  ///
  /// When `false` (default), side sheets appear as overlays on top of the content.
  /// When `true`, side sheets push the main content aside (like a drawer).
  ///
  /// **Requirements for push behavior:**
  /// - Your page must be wrapped in a [Scaffold]
  /// - You must provide a [scaffoldKey] parameter
  /// - Only applies to side sheet modes ([AdaptiveSelectorMode.leftSheet] and [AdaptiveSelectorMode.rightSheet])
  ///
  /// **Example with push behavior:**
  /// ```dart
  /// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ///
  /// Scaffold(
  ///   key: _scaffoldKey,
  ///   body: Column(
  ///     children: [
  ///       AdaptiveSelector.sideSheet(
  ///         isLeft: false,
  ///         options: items,
  ///         selectedValue: selected,
  ///         onChanged: (value) => setState(() => selected = value),
  ///         itemBuilder: (context, item) => Text(item),
  ///         usePushBehavior: true,
  ///         scaffoldKey: _scaffoldKey,
  ///       ),
  ///     ],
  ///   ),
  /// )
  /// ```
  final bool usePushBehavior;

  /// The [GlobalKey] for the [Scaffold] widget.
  ///
  /// Required when [usePushBehavior] is `true` for side sheet modes.
  /// This key is used to control the Scaffold's drawer/endDrawer.
  ///
  /// Example:
  /// ```dart
  /// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ///
  /// AdaptiveSelector.sideSheet(
  ///   isLeft: false,
  ///   options: items,
  ///   selectedValue: selected,
  ///   onChanged: (value) => setState(() => selected = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   usePushBehavior: true,
  ///   scaffoldKey: _scaffoldKey,
  /// )
  /// ```
  final GlobalKey<ScaffoldState>? scaffoldKey;

  /// Enables contextual push animation when showing side sheets.
  ///
  /// When true, the main app content slightly shifts in the direction of the sheet
  /// based on the relative screen position of the element that triggered it.
  /// Creates a more spatially-aware and context-driven opening animation.
  final bool useContextualPush;

  /// Optionally provide the global position of the triggering element.
  /// If null, the push will default to the sheet's side direction.
  final Offset? triggerPosition;

  /// The maximum horizontal offset (in logical pixels) to apply to the main content during contextual push.
  final double maxContextualPushOffset;

  /// Callback fired with the computed horizontal offset (in logical pixels).
  /// Use it to shift your page content (e.g., AnimatedSlide/Transform).
  final ValueChanged<double>? onContextualPushOffsetChanged;

  /// Callback fired with the normalized pivot Y of the triggering widget (0.0 top → 1.0 bottom).
  /// Useful when you want to add a slight rotation around the trigger's vertical position.
  /// Example: use `Alignment(0, pivotY * 2 - 1)` as the alignment for a rotation Transform.
  final ValueChanged<double>? onContextualPushPivotYChanged;

  /// Callback fired with the normalized pivot X (0.0 left � 1.0 right) of the triggering widget.
  /// Useful to anchor horizontal effects (e.g., compute dxFraction relative to the trigger X).
  final ValueChanged<double>? onContextualPushPivotXChanged;

  /// Optional [LayerLink] for anchored panel mode.
  ///
  /// When provided, the selector will display as an anchored panel positioned
  /// relative to the widget wrapped with [CompositedTransformTarget] using this link.
  ///
  /// This enables context-aware positioning where the selector appears next to
  /// the trigger widget instead of as a full-screen overlay.
  ///
  /// **Use Cases:**
  /// - Calendar applications (options next to selected time slot)
  /// - Timeline/scheduler interfaces (selector adjacent to clicked item)
  /// - Data grids/tables (options next to selected cell)
  /// - Context menus and popovers
  ///
  /// **Example:**
  /// ```dart
  /// final LayerLink _anchorLink = LayerLink();
  ///
  /// // No need to wrap with CompositedTransformTarget!
  /// // The selector handles it internally.
  /// AdaptiveSelector<String>(
  ///   options: ['Option 1', 'Option 2', 'Option 3'],
  ///   selectedValue: selectedValue,
  ///   onChanged: (value) => setState(() => selectedValue = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   anchorLink: _anchorLink,
  ///   anchorPosition: AnchorPosition.right,
  ///   anchorOffset: Offset(8, 0),
  /// )
  /// ```
  ///
  /// When [anchorLink] is provided:
  /// - The [mode] parameter is ignored
  /// - The selector displays as a compact floating panel
  /// - Position is automatically adjusted based on available screen space
  final LayerLink? anchorLink;

  /// The preferred position for the anchored panel relative to the anchor widget.
  ///
  /// Only applies when [anchorLink] is provided.
  ///
  /// Available positions:
  /// - [AnchorPosition.auto]: Automatically choose best position (default)
  /// - [AnchorPosition.right]: Position to the right of anchor
  /// - [AnchorPosition.left]: Position to the left of anchor
  /// - [AnchorPosition.bottom]: Position below anchor
  /// - [AnchorPosition.top]: Position above anchor
  ///
  /// The panel will automatically flip to the opposite position if there's
  /// not enough space in the preferred direction.
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: items,
  ///   selectedValue: selected,
  ///   onChanged: (value) => setState(() => selected = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   anchorLink: _anchorLink,
  ///   anchorPosition: AnchorPosition.right, // Prefer right side
  /// )
  /// ```
  final AnchorPosition anchorPosition;

  /// The offset (spacing) between the anchor widget and the anchored panel.
  ///
  /// Only applies when [anchorLink] is provided.
  ///
  /// - For horizontal positions (left/right): `dx` controls horizontal spacing
  /// - For vertical positions (top/bottom): `dy` controls vertical spacing
  ///
  /// Default: `Offset(8, 0)` (8px horizontal spacing)
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
  ///   anchorOffset: Offset(12, 0), // 12px spacing from anchor
  /// )
  /// ```
  final Offset anchorOffset;

  /// The width of the anchored panel in pixels.
  ///
  /// Only applies when [anchorLink] is provided.
  ///
  /// Default: 300px
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector<String>(
  ///   options: items,
  ///   selectedValue: selected,
  ///   onChanged: (value) => setState(() => selected = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   anchorLink: _anchorLink,
  ///   anchorPanelWidth: 400, // 400px wide panel
  /// )
  /// ```
  final double anchorPanelWidth;

  /// Optional custom widget to display at the top of mobile bottom sheets and side sheets.
  /// Can be used for headers, filters, or any custom content.
  final Widget? headerWidget;

  /// Optional custom widget to display at the bottom of mobile bottom sheets and side sheets.
  /// Can be used for footers, action buttons, or any custom content.
  final Widget? footerWidget;

  const AdaptiveSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    this.enableSearch = false,
    this.style,
    this.hint,
    this.breakpoint = 600,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.dropdownHeaderWidget,
    this.dropdownFooterWidget,
    this.autoCloseWhenSelect = true,
    this.mode = AdaptiveSelectorMode.automatic,
    this.sideSheetSize = SideSheetSize.medium,
    this.useSafeArea = true,
    this.usePushBehavior = false,
    this.scaffoldKey,
    this.useContextualPush = false,
    this.triggerPosition,
    this.maxContextualPushOffset = 24.0,
    this.onContextualPushOffsetChanged,
    this.onContextualPushPivotYChanged,
    this.onContextualPushPivotXChanged,
    this.anchorLink,
    this.anchorPosition = AnchorPosition.auto,
    this.anchorOffset = const Offset(8, 0),
    this.anchorPanelWidth = 300,
    this.headerWidget,
    this.footerWidget,
  }) : selectedValues = const [],
       onSelectionChanged = null,
       selectedValuesBuilder = null,
       isMultiSelect = false;

  /// Explicit adaptive constructor for discoverability.
  ///
  /// Equivalent to the default constructor with mode: AdaptiveSelectorMode.automatic.
  const AdaptiveSelector.adaptive({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    this.enableSearch = false,
    this.style,
    this.hint,
    this.breakpoint = 600,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.dropdownHeaderWidget,
    this.dropdownFooterWidget,
    this.autoCloseWhenSelect = true,
    this.sideSheetSize = SideSheetSize.medium,
    this.useSafeArea = true,
    this.usePushBehavior = false,
    this.scaffoldKey,
    this.useContextualPush = false,
    this.triggerPosition,
    this.maxContextualPushOffset = 24.0,
    this.onContextualPushOffsetChanged,
    this.onContextualPushPivotYChanged,
    this.onContextualPushPivotXChanged,
    this.anchorLink,
    this.anchorPosition = AnchorPosition.auto,
    this.anchorOffset = const Offset(8, 0),
    this.anchorPanelWidth = 300,
    this.headerWidget,
    this.footerWidget,
  }) : mode = AdaptiveSelectorMode.automatic,
       selectedValues = const [],
       onSelectionChanged = null,
       selectedValuesBuilder = null,
       isMultiSelect = false;

  /// Creates a side sheet selector.
  ///
  /// The side sheet slides in from the left or right edge of the screen.
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector.sideSheet(
  ///   isLeft: false, // Right side sheet
  ///   options: ['Option 1', 'Option 2', 'Option 3'],
  ///   selectedValue: selectedOption,
  ///   onChanged: (value) => setState(() => selectedOption = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   sideSheetSize: SideSheetSize.medium,
  /// )
  /// ```
  const AdaptiveSelector.sideSheet({
    super.key,
    required bool isLeft,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    this.enableSearch = false,
    this.style,
    this.hint,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.sideSheetSize = SideSheetSize.medium,
    this.useSafeArea = true,
    this.usePushBehavior = false,
    this.scaffoldKey,
    this.useContextualPush = false,
    this.triggerPosition,
    this.maxContextualPushOffset = 24.0,
    this.onContextualPushOffsetChanged,
    this.onContextualPushPivotYChanged,
    this.onContextualPushPivotXChanged,
    this.headerWidget,
    this.footerWidget,
  }) : mode = isLeft
           ? AdaptiveSelectorMode.leftSheet
           : AdaptiveSelectorMode.rightSheet,
       breakpoint = 600,
       dropdownHeaderWidget = null,
       dropdownFooterWidget = null,
       anchorLink = null,
       anchorPosition = AnchorPosition.auto,
       anchorOffset = const Offset(8, 0),
       anchorPanelWidth = 300,
       autoCloseWhenSelect = true,
       selectedValues = const [],
       onSelectionChanged = null,
       selectedValuesBuilder = null,
       isMultiSelect = false;

  /// Creates a bottom sheet selector.
  ///
  /// The bottom sheet slides up from the bottom of the screen.
  /// This is the default mobile UI mode.
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector.bottomSheet(
  ///   options: ['Option 1', 'Option 2', 'Option 3'],
  ///   selectedValue: selectedOption,
  ///   onChanged: (value) => setState(() => selectedOption = value),
  ///   itemBuilder: (context, item) => Text(item),
  ///   enableSearch: true,
  /// )
  /// ```
  const AdaptiveSelector.bottomSheet({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    this.enableSearch = false,
    this.style,
    this.hint,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.useSafeArea = true,
    this.headerWidget,
    this.footerWidget,
    // Multi-select support (optional; defaults keep single-select behavior)
    this.selectedValues = const [],
    this.onSelectionChanged,
    this.selectedValuesBuilder,
    this.isMultiSelect = false,
  }) : mode = AdaptiveSelectorMode.bottomSheet,
       breakpoint = 600,
       dropdownHeaderWidget = null,
       dropdownFooterWidget = null,
       sideSheetSize = SideSheetSize.medium,
       usePushBehavior = false,
       scaffoldKey = null,
       useContextualPush = false,
       triggerPosition = null,
       maxContextualPushOffset = 24.0,
       onContextualPushOffsetChanged = null,
       onContextualPushPivotYChanged = null,
       onContextualPushPivotXChanged = null,
       anchorLink = null,
       anchorPosition = AnchorPosition.auto,
       anchorOffset = const Offset(8, 0),
       anchorPanelWidth = 300,
       autoCloseWhenSelect = true;

  /// Creates a dropdown selector.
  ///
  /// The dropdown appears below the trigger widget.
  /// This is the default desktop UI mode.
  ///
  /// Example:
  /// ```dart
  /// AdaptiveSelector.dropdown(
  ///   options: ['Option 1', 'Option 2', 'Option 3'],
  ///   selectedValue: selectedOption,
  ///   onChanged: (value) => setState(() => selectedOption = value),
  ///   itemBuilder: (context, item) => Text(item),

  /// Programmatic API entry point (nested style):
  /// Example: await AdaptiveSelector.show.sideSheet(...)
  static final show = AdaptiveSelectorShow._();

  ///   dropdownHeaderWidget: Text('Select an option'),
  /// )
  /// ```
  const AdaptiveSelector.dropdown({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    this.enableSearch = false,
    this.style,
    this.hint,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.dropdownHeaderWidget,
    this.dropdownFooterWidget,
    this.autoCloseWhenSelect = true,
    // Multi-select support (optional; defaults keep single-select behavior)
    this.selectedValues = const [],
    this.onSelectionChanged,
    this.selectedValuesBuilder,
    this.isMultiSelect = false,
  }) : mode = AdaptiveSelectorMode.dropdown,
       breakpoint = 600,
       sideSheetSize = SideSheetSize.medium,
       useSafeArea = true,
       usePushBehavior = false,
       scaffoldKey = null,
       useContextualPush = false,
       triggerPosition = null,
       maxContextualPushOffset = 24.0,
       onContextualPushOffsetChanged = null,
       onContextualPushPivotYChanged = null,
       onContextualPushPivotXChanged = null,
       anchorLink = null,
       anchorPosition = AnchorPosition.auto,
       anchorOffset = const Offset(8, 0),
       anchorPanelWidth = 300,
       headerWidget = null,
       footerWidget = null;

  /// Programmatically open a side sheet overlay with optional contextual push.
  ///
  /// Either provide list-mode params (options/onChanged/itemBuilder), or supply a
  /// fully custom builder via [customBuilder]. When [customBuilder] is provided,
  /// list params can be omitted.
  ///
  /// The [itemBuilder] callback receives three parameters:
  /// - BuildContext: the build context
  /// - T: the item to build
  /// - bool: whether the item is currently selected
  @Deprecated(
    'Use AdaptiveSelector.show.sideSheet() instead. This method will be removed in a future major release.',
  )
  static Future<void> openSideSheetOverlay<T>({
    required BuildContext context,
    required bool isLeftSide,
    SideSheetSize size = SideSheetSize.medium,
    AdaptiveSelectorStyle style = const AdaptiveSelectorStyle(),
    // List-mode (optional when using customBuilder)
    List<T> options = const [],
    T? selectedValue,
    void Function(T value)? onChanged,
    Widget Function(BuildContext, T, bool)? itemBuilder,
    bool enableSearch = false,
    String? hint,
    Future<List<T>> Function(String query)? onSearch,
    Widget? loadingWidget,
    bool isLoading = false,
    Widget? headerWidget,
    Widget? footerWidget,
    bool useSafeArea = true,
    // Contextual push
    bool useContextualPush = false,
    Offset? triggerPosition,
    double maxContextualPushOffset = 24.0,
    ValueChanged<double>? onContextualPushOffsetChanged,
    ValueChanged<double>? onContextualPushPivotYChanged,
    ValueChanged<double>? onContextualPushPivotXChanged,
    // Fully custom content builder (bypasses list rendering when provided)
    Widget Function(BuildContext, void Function(T), VoidCallback)?
    customBuilder,
  }) {
    return AdaptiveSelector.show.sideSheet<T>(
      context: context,
      isLeftSide: isLeftSide,
      size: size,
      style: style,
      options: options,
      selectedValue: selectedValue,
      onChanged: onChanged,
      itemBuilder: itemBuilder,
      enableSearch: enableSearch,
      hint: hint,
      onSearch: onSearch,
      loadingWidget: loadingWidget,
      isLoading: isLoading,
      headerWidget: headerWidget,
      footerWidget: footerWidget,
      customBuilder: customBuilder,
      useSafeArea: useSafeArea,
      useContextualPush: useContextualPush,
      triggerPosition: triggerPosition,
      maxContextualPushOffset: maxContextualPushOffset,
      onContextualPushOffsetChanged: onContextualPushOffsetChanged,
      onContextualPushPivotYChanged: onContextualPushPivotYChanged,
      onContextualPushPivotXChanged: onContextualPushPivotXChanged,
    );
  }

  @override
  State<AdaptiveSelector<T>> createState() => _AdaptiveSelectorState<T>();
}

class _AdaptiveSelectorState<T> extends State<AdaptiveSelector<T>> {
  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? const AdaptiveSelectorStyle();

    // If anchorLink is provided, use anchored panel mode
    if (widget.anchorLink != null) {
      return _buildAnchoredPanel(effectiveStyle);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine which UI to show based on mode
        switch (widget.mode) {
          case AdaptiveSelectorMode.automatic:
            // Use breakpoint to determine UI
            final shouldShowDesktop = constraints.maxWidth >= widget.breakpoint;
            if (shouldShowDesktop) {
              return _buildDesktopDropdown(effectiveStyle);
            } else {
              return _buildMobileBottomSheet(effectiveStyle);
            }

          case AdaptiveSelectorMode.alwaysMobile:
          case AdaptiveSelectorMode.bottomSheet:
            // Force mobile UI (bottom sheet)
            return _buildMobileBottomSheet(effectiveStyle);

          case AdaptiveSelectorMode.alwaysDesktop:
          case AdaptiveSelectorMode.dropdown:
            // Force desktop UI (dropdown)
            return _buildDesktopDropdown(effectiveStyle);

          case AdaptiveSelectorMode.leftSheet:
            // Side sheet from left
            return _buildSideSheet(effectiveStyle, isLeftSide: true);

          case AdaptiveSelectorMode.rightSheet:
            // Side sheet from right
            return _buildSideSheet(effectiveStyle, isLeftSide: false);
        }
      },
    );
  }

  Widget _buildDesktopDropdown(AdaptiveSelectorStyle style) {
    return DesktopDropdown<T>(
      options: widget.options,
      selectedValue: widget.selectedValue,
      onChanged: widget.onChanged,
      itemBuilder: widget.itemBuilder,
      enableSearch: widget.enableSearch,
      style: style,
      hint: widget.hint,
      onSearch: widget.onSearch,
      loadingWidget: widget.loadingWidget,
      isLoading: widget.isLoading,
      dropdownHeaderWidget: widget.dropdownHeaderWidget,
      dropdownFooterWidget: widget.dropdownFooterWidget,
      autoCloseWhenSelect: widget.autoCloseWhenSelect,
      // Multi-select wiring
      isMultiSelect: widget.isMultiSelect,
      selectedValues: widget.selectedValues,
      onSelectionChanged: widget.onSelectionChanged,
      selectedValuesBuilder: widget.selectedValuesBuilder,
    );
  }

  Widget _buildMobileBottomSheet(AdaptiveSelectorStyle style) {
    return MobileBottomSheet<T>(
      options: widget.options,
      selectedValue: widget.selectedValue,
      onChanged: widget.onChanged,
      itemBuilder: widget.itemBuilder,
      enableSearch: widget.enableSearch,
      style: style,
      hint: widget.hint,
      onSearch: widget.onSearch,
      loadingWidget: widget.loadingWidget,
      isLoading: widget.isLoading,
      headerWidget: widget.headerWidget,
      footerWidget: widget.footerWidget,
      useSafeArea: widget.useSafeArea,
      selectedValues: widget.selectedValues,
      onSelectionChanged: widget.onSelectionChanged,
      selectedValuesBuilder: widget.selectedValuesBuilder,
      isMultiSelect: widget.isMultiSelect,
    );
  }

  Widget _buildSideSheet(
    AdaptiveSelectorStyle style, {
    required bool isLeftSide,
  }) {
    return SideSheet<T>(
      options: widget.options,
      selectedValue: widget.selectedValue,
      onChanged: widget.onChanged,
      itemBuilder: widget.itemBuilder,
      enableSearch: widget.enableSearch,
      style: style,
      hint: widget.hint,
      onSearch: widget.onSearch,
      loadingWidget: widget.loadingWidget,
      isLoading: widget.isLoading,
      headerWidget: widget.headerWidget,
      footerWidget: widget.footerWidget,
      isLeftSide: isLeftSide,
      size: widget.sideSheetSize,
      useSafeArea: widget.useSafeArea,
      usePushBehavior: widget.usePushBehavior,
      scaffoldKey: widget.scaffoldKey,
      useContextualPush: widget.useContextualPush,
      triggerPosition: widget.triggerPosition,
      maxContextualPushOffset: widget.maxContextualPushOffset,
      onContextualPushOffsetChanged: widget.onContextualPushOffsetChanged,
      onContextualPushPivotYChanged: widget.onContextualPushPivotYChanged,
      onContextualPushPivotXChanged: widget.onContextualPushPivotXChanged,
    );
  }

  Widget _buildAnchoredPanel(AdaptiveSelectorStyle style) {
    return AnchoredPanel<T>(
      options: widget.options,
      selectedValue: widget.selectedValue,
      onChanged: widget.onChanged,
      itemBuilder: widget.itemBuilder,
      enableSearch: widget.enableSearch,
      style: style,
      hint: widget.hint,
      onSearch: widget.onSearch,
      loadingWidget: widget.loadingWidget,
      isLoading: widget.isLoading,
      headerWidget: widget.headerWidget,
      footerWidget: widget.footerWidget,
      anchorLink: widget.anchorLink!,
      anchorPosition: widget.anchorPosition,
      anchorOffset: widget.anchorOffset,
      panelWidth: widget.anchorPanelWidth,
    );
  }
}

/// Nested programmatic API namespace: AdaptiveSelector.show
class AdaptiveSelectorShow {
  const AdaptiveSelectorShow._();

  /// Programmatically open a side sheet overlay (nested style).
  /// Usage: await AdaptiveSelector.show.sideSheet(...)
  ///
  /// The [itemBuilder] callback receives three parameters:
  /// - BuildContext: the build context
  /// - T: the item to build
  /// - bool: whether the item is currently selected
  Future<void> sideSheet<T>({
    required BuildContext context,
    required bool isLeftSide,
    SideSheetSize size = SideSheetSize.medium,
    AdaptiveSelectorStyle style = const AdaptiveSelectorStyle(),
    // List-mode (optional when using customBuilder)
    List<T> options = const [],
    T? selectedValue,
    void Function(T value)? onChanged,
    Widget Function(BuildContext, T, bool)? itemBuilder,
    bool enableSearch = false,
    String? hint,
    Future<List<T>> Function(String query)? onSearch,
    Widget? loadingWidget,
    bool isLoading = false,
    Widget? headerWidget,
    Widget? footerWidget,
    bool useSafeArea = true,
    bool autoCloseOnSelect = true,
    // Contextual push
    bool useContextualPush = false,
    Offset? triggerPosition,
    double maxContextualPushOffset = 24.0,
    ValueChanged<double>? onContextualPushOffsetChanged,
    ValueChanged<double>? onContextualPushPivotYChanged,
    ValueChanged<double>? onContextualPushPivotXChanged,
    // Fully custom content builder (bypasses list rendering when provided)
    Widget Function(BuildContext, void Function(T), VoidCallback)?
    customBuilder,
  }) {
    return SideSheet.openOverlay<T>(
      context: context,
      isLeftSide: isLeftSide,
      size: size,
      style: style,
      options: options,
      selectedValue: selectedValue,
      onChanged: onChanged,
      itemBuilder: itemBuilder,
      enableSearch: enableSearch,
      hint: hint,
      onSearch: onSearch,
      loadingWidget: loadingWidget,
      isLoading: isLoading,
      headerWidget: headerWidget,
      footerWidget: footerWidget,
      customBuilder: customBuilder,
      useSafeArea: useSafeArea,
      autoCloseOnSelect: autoCloseOnSelect,
      useContextualPush: useContextualPush,
      triggerPosition: triggerPosition,
      maxContextualPushOffset: maxContextualPushOffset,
      onContextualPushOffsetChanged: onContextualPushOffsetChanged,
      onContextualPushPivotYChanged: onContextualPushPivotYChanged,
      onContextualPushPivotXChanged: onContextualPushPivotXChanged,
    );
  }

  /// Programmatically open a bottom sheet (mobile-style) overlay.
  /// Usage: await AdaptiveSelector.show.bottomSheet(...)
  /// Programmatically open a mobile-style bottom sheet.
  ///
  /// The [itemBuilder] callback receives three parameters:
  /// - BuildContext: the build context
  /// - T: the item to build
  /// - bool: whether the item is currently selected
  Future<void> bottomSheet<T>({
    required BuildContext context,
    AdaptiveSelectorStyle style = const AdaptiveSelectorStyle(),
    // List-mode (optional when using customBuilder)
    List<T> options = const [],
    T? selectedValue,
    void Function(T value)? onChanged,
    Widget Function(BuildContext, T, bool)? itemBuilder,
    bool enableSearch = false,
    String? hint,
    Future<List<T>> Function(String query)? onSearch,
    Widget? loadingWidget,
    bool isLoading = false,
    Widget? headerWidget,
    Widget? footerWidget,
    bool useSafeArea = true,
    // Bottom sheet maximum height in logical pixels. Defaults to 75% of screen height.
    double? maxHeight,
    // Whether select(value) should auto-close (defaults to false in multi-select mode)
    bool? autoCloseOnSelect,
    // Multi-select support
    List<T> selectedValues = const [],
    ValueChanged<List<T>>? onSelectionChanged,
    Widget Function(BuildContext, List<T>)? selectedValuesBuilder,
    bool isMultiSelect = false,
    // Fully custom content builder (bypasses list rendering when provided)
    Widget Function(BuildContext, void Function(T), VoidCallback)?
    customBuilder,
  }) {
    return MobileBottomSheet.openModal<T>(
      context: context,
      style: style,
      options: options,
      selectedValue: selectedValue,
      onChanged: onChanged,
      itemBuilder: itemBuilder,
      enableSearch: enableSearch,
      hint: hint,
      onSearch: onSearch,
      loadingWidget: loadingWidget,
      isLoading: isLoading,
      headerWidget: headerWidget,
      footerWidget: footerWidget,
      useSafeArea: useSafeArea,
      maxHeight: maxHeight,
      autoCloseOnSelect: autoCloseOnSelect,
      selectedValues: selectedValues,
      onSelectionChanged: onSelectionChanged,
      selectedValuesBuilder: selectedValuesBuilder,
      isMultiSelect: isMultiSelect,
      customBuilder: customBuilder,
    );
  }

  /// Programmatically open a desktop-style dropdown overlay.
  ///
  /// **Anchoring Options:**
  /// - [anchorLink]: Provide a LayerLink (you must wrap your anchor widget
  ///   with CompositedTransformTarget yourself). This is the recommended approach
  ///   as it's not affected by drawer opening/closing or RTL/LTR layout changes.
  /// - [selectorKey]: Provide a GlobalKey pointing to the anchor widget. The library
  ///   will automatically compute the anchor Rect from the key's RenderBox.
  /// - [anchorRect]: Provide an explicit Rect for positioning (uses global coordinates,
  ///   may be affected by layout changes).
  ///
  /// If none are provided, the dropdown will default to top-left at (0,0) which is
  /// rarely desired.
  ///
  /// The [itemBuilder] callback receives three parameters:
  /// - BuildContext: the build context
  /// - T: the item to build
  /// - bool: whether the item is currently selected
  Future<void> dropdown<T>({
    required BuildContext context,
    AdaptiveSelectorStyle style = const AdaptiveSelectorStyle(),
    // List-mode
    List<T> options = const [],
    T? selectedValue,
    void Function(T value)? onChanged,
    Widget Function(BuildContext, T, bool)? itemBuilder,
    bool enableSearch = false,
    String? hint,
    Future<List<T>> Function(String query)? onSearch,
    Widget? loadingWidget,
    bool isLoading = false,
    Widget? headerWidget,
    Widget? footerWidget,
    // Multi-select support (optional)
    List<T> selectedValues = const [],
    ValueChanged<List<T>>? onSelectionChanged,
    bool isMultiSelect = false,
    // Fully custom content builder (bypasses list rendering when provided)
    Widget Function(BuildContext, void Function(T), VoidCallback)?
    customBuilder,
    // Whether select(value) should auto-close (applies to customBuilder and default list)
    bool autoCloseOnSelect = true,

    // Anchoring
    LayerLink? anchorLink,
    Rect? anchorRect,
    GlobalKey? selectorKey,
    double panelWidth =
        0, // 0 => derive from anchorRect.width or fallback to 300
    double anchorHeight = 40,
    double verticalOffset = 5,
  }) {
    assert(
      customBuilder != null || (onChanged != null && itemBuilder != null),
      'Provide either customBuilder or both onChanged and itemBuilder',
    );

    // Strategy: Prefer LayerLink over Rect-based positioning for better RTL support
    // 1. If anchorLink is provided, use it directly
    // 2. If selectorKey is provided, create a LayerLink internally and wrap the anchor
    // 3. Otherwise, fall back to anchorRect (Rect-based positioning)

    LayerLink? effectiveAnchorLink = anchorLink;
    Rect? effectiveAnchorRect = anchorRect;
    double effectiveAnchorHeight = anchorHeight;

    // If selectorKey is provided and no anchorLink, create LayerLink internally
    if (effectiveAnchorLink == null &&
        selectorKey != null &&
        anchorRect == null) {
      final ctx = selectorKey.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          // Create a LayerLink and attach it to the anchor's RenderBox
          effectiveAnchorLink = LayerLink();
          effectiveAnchorHeight = box.size.height;

          // We need to wrap the anchor with CompositedTransformTarget
          // But since this is a programmatic API, we can't modify the widget tree
          // So we fall back to Rect-based positioning with improved RTL handling
          final topLeft = box.localToGlobal(Offset.zero);
          final size = box.size;
          effectiveAnchorRect = Rect.fromLTWH(
            topLeft.dx,
            topLeft.dy,
            size.width,
            size.height,
          );
          effectiveAnchorLink =
              null; // Can't use LayerLink without wrapping the anchor
        }
      }
    } else if (effectiveAnchorRect == null && selectorKey != null) {
      // Derive anchorRect from selectorKey when no anchorLink or anchorRect provided
      final ctx = selectorKey.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          final size = box.size;
          effectiveAnchorRect = Rect.fromLTWH(
            topLeft.dx,
            topLeft.dy,
            size.width,
            size.height,
          );
          effectiveAnchorHeight = size.height;
        }
      }
    }

    return DesktopDropdownOverlay.openOverlay<T>(
      context: context,
      style: style,
      options: options,
      selectedValue: selectedValue,
      onChanged: onChanged,
      itemBuilder: itemBuilder,
      enableSearch: enableSearch,
      hint: hint,
      onSearch: onSearch,
      loadingWidget: loadingWidget,
      isLoading: isLoading,
      headerWidget: headerWidget,
      footerWidget: footerWidget,
      // Multi-select threading
      selectedValues: selectedValues,
      onSelectionChanged: onSelectionChanged,
      isMultiSelect: isMultiSelect,
      customBuilder: customBuilder,
      autoCloseOnSelect: isMultiSelect ? false : autoCloseOnSelect,
      anchorLink: effectiveAnchorLink,
      anchorRect: effectiveAnchorRect,
      panelWidth: panelWidth,
      anchorHeight: effectiveAnchorHeight,
      verticalOffset: verticalOffset,
    );
  }

  /// Programmatic API: chooses dropdown for large screens (>= [breakpoint])
  /// and bottom sheet for small screens. In dropdown mode, [anchorLink]/[anchorRect]
  /// or [selectorKey] are used for positioning; they are ignored for bottom sheet.
  ///
  /// The [itemBuilder] callback receives three parameters for dropdown mode:
  /// - BuildContext: the build context
  /// - T: the item to build
  /// - bool: whether the item is currently selected
  ///
  /// For bottom sheet mode, the isSelected parameter is ignored.
  Future<void> dropdownOrSheet<T>({
    required BuildContext context,
    double breakpoint = 600,
    // Common parameters
    AdaptiveSelectorStyle style = const AdaptiveSelectorStyle(),
    List<T> options = const [],
    T? selectedValue,
    void Function(T value)? onChanged,
    Widget Function(BuildContext, T, bool)? itemBuilder,
    bool enableSearch = false,
    String? hint,
    Future<List<T>> Function(String query)? onSearch,
    Widget? loadingWidget,
    bool isLoading = false,
    Widget? headerWidget,
    Widget? footerWidget,
    bool useSafeArea = true,
    bool? autoCloseOnSelect,
    // Multi-select support
    List<T> selectedValues = const [],
    ValueChanged<List<T>>? onSelectionChanged,
    Widget Function(BuildContext, List<T>)? selectedValuesBuilder,
    bool isMultiSelect = false,
    // Custom content
    Widget Function(BuildContext, void Function(T), VoidCallback)?
    customBuilder,
    // BottomSheet-only options (ignored for dropdown)
    double? bottomSheetMaxHeight,
    // Dropdown-only anchors (ignored for bottom sheet)
    LayerLink? anchorLink,
    Rect? anchorRect,
    GlobalKey? selectorKey,
    double panelWidth = 0,
    double anchorHeight = 40,
    double verticalOffset = 5,
  }) {
    final width = MediaQuery.of(context).size.width;

    // Derive anchorRect from selectorKey when provided and no explicit anchorRect
    Rect? effectiveAnchorRect = anchorRect;
    if (effectiveAnchorRect == null && selectorKey != null) {
      final ctx = selectorKey.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final topLeft = box.localToGlobal(Offset.zero);
          final size = box.size;
          effectiveAnchorRect = Rect.fromLTWH(
            topLeft.dx,
            topLeft.dy,
            size.width,
            size.height,
          );
        }
      }
    }

    if (width < breakpoint) {
      return bottomSheet<T>(
        context: context,
        style: style,
        options: options,
        selectedValue: selectedValue,
        onChanged: onChanged,
        itemBuilder: itemBuilder,
        enableSearch: enableSearch,
        hint: hint,
        onSearch: onSearch,
        loadingWidget: loadingWidget,
        isLoading: isLoading,
        headerWidget: headerWidget,
        footerWidget: footerWidget,
        useSafeArea: useSafeArea,
        maxHeight: bottomSheetMaxHeight,
        autoCloseOnSelect: autoCloseOnSelect,
        selectedValues: selectedValues,
        onSelectionChanged: onSelectionChanged,
        selectedValuesBuilder: selectedValuesBuilder,
        isMultiSelect: isMultiSelect,
        customBuilder: customBuilder,
      );
    } else {
      return dropdown<T>(
        context: context,
        style: style,
        options: options,
        selectedValue: selectedValue,
        onChanged: onChanged,
        itemBuilder: itemBuilder,
        enableSearch: enableSearch,
        hint: hint,
        onSearch: onSearch,
        loadingWidget: loadingWidget,
        isLoading: isLoading,
        headerWidget: headerWidget,
        footerWidget: footerWidget,
        customBuilder: customBuilder,
        autoCloseOnSelect: autoCloseOnSelect ?? true,
        selectedValues: selectedValues,
        onSelectionChanged: onSelectionChanged,
        isMultiSelect: isMultiSelect,
        anchorLink: anchorLink,
        anchorRect: effectiveAnchorRect,
        panelWidth: panelWidth,
        anchorHeight: anchorHeight,
        verticalOffset: verticalOffset,
      );
    }
  }

  /// Programmatic automatic mode: chooses BottomSheet for small screens and
  /// SideSheet for large screens based on [breakpoint]. For desktop, the side
  /// sheet opens on the left by default unless [isLeftSide] is set to false.
  ///
  /// The [itemBuilder] callback receives three parameters:
  /// - BuildContext: the build context
  /// - T: the item to build
  /// - bool: whether the item is currently selected
  Future<void> adaptive<T>({
    required BuildContext context,
    double breakpoint = 600,
    // Common parameters
    AdaptiveSelectorStyle style = const AdaptiveSelectorStyle(),
    List<T> options = const [],
    T? selectedValue,
    void Function(T value)? onChanged,
    Widget Function(BuildContext, T, bool)? itemBuilder,
    bool enableSearch = false,
    String? hint,
    Future<List<T>> Function(String query)? onSearch,
    Widget? loadingWidget,
    bool isLoading = false,
    Widget? headerWidget,
    Widget? footerWidget,
    bool useSafeArea = true,
    bool? autoCloseOnSelect,
    // Multi-select support
    List<T> selectedValues = const [],
    ValueChanged<List<T>>? onSelectionChanged,
    Widget Function(BuildContext, List<T>)? selectedValuesBuilder,
    bool isMultiSelect = false,
    // Custom content
    Widget Function(BuildContext, void Function(T), VoidCallback)?
    customBuilder,
    // BottomSheet-only options (ignored when using SideSheet)
    double? bottomSheetMaxHeight,
    // SideSheet specific when desktop
    bool isLeftSide = true,
    bool useContextualPush = false,
    Offset? triggerPosition,
    double maxContextualPushOffset = 24.0,
    ValueChanged<double>? onContextualPushOffsetChanged,
    ValueChanged<double>? onContextualPushPivotYChanged,
    ValueChanged<double>? onContextualPushPivotXChanged,
    SideSheetSize sideSheetSize = SideSheetSize.medium,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpoint) {
      return bottomSheet<T>(
        context: context,
        style: style,
        options: options,
        selectedValue: selectedValue,
        onChanged: onChanged,
        itemBuilder: itemBuilder,
        enableSearch: enableSearch,
        hint: hint,
        onSearch: onSearch,
        loadingWidget: loadingWidget,
        isLoading: isLoading,
        headerWidget: headerWidget,
        footerWidget: footerWidget,
        useSafeArea: useSafeArea,
        maxHeight: bottomSheetMaxHeight,
        autoCloseOnSelect: autoCloseOnSelect,
        selectedValues: selectedValues,
        onSelectionChanged: onSelectionChanged,
        selectedValuesBuilder: selectedValuesBuilder,
        isMultiSelect: isMultiSelect,
        customBuilder: customBuilder,
      );
    } else {
      return sideSheet<T>(
        context: context,
        isLeftSide: isLeftSide,
        size: sideSheetSize,
        style: style,
        options: options,
        selectedValue: selectedValue,
        onChanged: onChanged,
        itemBuilder: itemBuilder,
        enableSearch: enableSearch,
        hint: hint,
        onSearch: onSearch,
        loadingWidget: loadingWidget,
        isLoading: isLoading,
        headerWidget: headerWidget,
        footerWidget: footerWidget,
        useSafeArea: useSafeArea,
        autoCloseOnSelect: autoCloseOnSelect ?? true,
        customBuilder: customBuilder,
        useContextualPush: useContextualPush,
        triggerPosition: triggerPosition,
        maxContextualPushOffset: maxContextualPushOffset,
        onContextualPushOffsetChanged: onContextualPushOffsetChanged,
        onContextualPushPivotYChanged: onContextualPushPivotYChanged,
        onContextualPushPivotXChanged: onContextualPushPivotXChanged,
      );
    }
  }
}

/// Programmatically open a side sheet overlay with optional contextual push.
///
/// This helper is provided for examples and advanced use-cases where the trigger
/// is not the AdaptiveSelector widget itself (e.g., a separate ElevatedButton).
///
/// For left sheets, pass `triggerPosition.dx` as the LEFT edge of the trigger;
/// for right sheets, pass it as the RIGHT edge of the trigger. `triggerPosition.dy`
/// should be the vertical center of the trigger to drive pivotY nicely.
@Deprecated(
  'Use AdaptiveSelector.show.sideSheet() instead. This function will be removed in a future major release.',
)
Future<void> openSideSheetOverlay<T>({
  required BuildContext context,
  required bool isLeftSide,
  SideSheetSize size = SideSheetSize.medium,
  AdaptiveSelectorStyle style = const AdaptiveSelectorStyle(),
  required List<T> options,
  required T? selectedValue,
  required void Function(T value) onChanged,
  required Widget Function(BuildContext, T, bool) itemBuilder,
  bool enableSearch = false,
  String? hint,
  Future<List<T>> Function(String query)? onSearch,
  Widget? loadingWidget,
  bool isLoading = false,
  Widget? headerWidget,
  Widget? footerWidget,
  bool useSafeArea = true,
  // Contextual push
  bool useContextualPush = false,
  Offset? triggerPosition,
  double maxContextualPushOffset = 24.0,
  ValueChanged<double>? onContextualPushOffsetChanged,
  ValueChanged<double>? onContextualPushPivotYChanged,
  ValueChanged<double>? onContextualPushPivotXChanged,
}) {
  return AdaptiveSelector.show.sideSheet<T>(
    context: context,
    isLeftSide: isLeftSide,
    size: size,
    style: style,
    options: options,
    selectedValue: selectedValue,
    onChanged: onChanged,
    itemBuilder: itemBuilder,
    enableSearch: enableSearch,
    hint: hint,
    onSearch: onSearch,
    loadingWidget: loadingWidget,
    isLoading: isLoading,
    headerWidget: headerWidget,
    footerWidget: footerWidget,
    useSafeArea: useSafeArea,
    useContextualPush: useContextualPush,
    triggerPosition: triggerPosition,
    maxContextualPushOffset: maxContextualPushOffset,
    onContextualPushOffsetChanged: onContextualPushOffsetChanged,
    onContextualPushPivotYChanged: onContextualPushPivotYChanged,
    onContextualPushPivotXChanged: onContextualPushPivotXChanged,
  );
}
