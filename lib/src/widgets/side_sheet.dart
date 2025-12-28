import 'package:flutter/material.dart';
import '../models/adaptive_selector_style.dart';
import '../models/side_sheet_size.dart';
import '../utils/search_helper.dart';
import 'loading_widget.dart';

typedef SideSheetCustomBuilder<T> =
    Widget Function(
      BuildContext context,
      void Function(T value) select,
      VoidCallback close,
    );

/// Side sheet implementation that slides in from left or right.
class SideSheet<T> extends StatefulWidget {
  final List<T>? options;
  final T? selectedValue;
  final void Function(T value)? onChanged;
  final Widget Function(BuildContext context, T item, bool isSelected)?
  itemBuilder;
  final bool enableSearch;
  final AdaptiveSelectorStyle style;
  final String? hint;
  final Future<List<T>> Function(String query)? onSearch;
  final Widget? loadingWidget;
  final bool isLoading;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final SideSheetCustomBuilder<T>? customBuilder;
  final bool isLeftSide; // true for left, false for right
  final SideSheetSize size; // Width size of the side sheet
  final bool useSafeArea; // Whether to wrap content in SafeArea
  final bool
  usePushBehavior; // Whether to use push behavior (drawer) instead of overlay
  final GlobalKey<ScaffoldState>?
  scaffoldKey; // Required when usePushBehavior is true

  // Contextual push (overlay) support
  final bool useContextualPush;
  final Offset? triggerPosition;
  final double maxContextualPushOffset;
  final ValueChanged<double>? onContextualPushOffsetChanged;
  // Normalized pivot Y for rotation/hinge effects (0.0 top → 1.0 bottom)
  final ValueChanged<double>? onContextualPushPivotYChanged;
  // Normalized pivot X for anchoring horizontal effects (0.0 left � 1.0 right)
  final ValueChanged<double>? onContextualPushPivotXChanged;

  const SideSheet({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    required this.enableSearch,
    required this.style,
    required this.isLeftSide,
    this.hint,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.headerWidget,
    this.footerWidget,
    this.customBuilder,
    this.size = SideSheetSize.medium,
    this.useSafeArea = true,
    this.usePushBehavior = false,
    this.scaffoldKey,
    this.useContextualPush = false,
    this.triggerPosition,
    this.maxContextualPushOffset = 24.0,
    this.onContextualPushOffsetChanged,
    this.onContextualPushPivotYChanged,
    this.onContextualPushPivotXChanged,
  });

  /// Programmatically open a side sheet overlay without needing a SideSheet widget in the tree.
  ///
  /// This mirrors the overlay branch of the internal `_showSideSheet` logic and also
  /// drives the contextual push callbacks when enabled. Provide `triggerPosition`
  /// using the triggering widget's edge coordinate for precise edge alignment:
  /// - For a left sheet, pass dx = trigger's LEFT edge and dy = trigger center Y.
  /// - For a right sheet, pass dx = trigger's RIGHT edge and dy = trigger center Y.
  ///
  /// The [itemBuilder] callback receives three parameters:
  /// - BuildContext: the build context
  /// - T: the item to build
  /// - bool: whether the item is currently selected
  static Future<void> openOverlay<T>({
    required BuildContext context,
    required bool isLeftSide,
    required SideSheetSize size,
    required AdaptiveSelectorStyle style,
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
    SideSheetCustomBuilder<T>? customBuilder,
    bool useSafeArea = true,
    bool autoCloseOnSelect = true,
    // Contextual push
    bool useContextualPush = false,
    Offset? triggerPosition,
    double maxContextualPushOffset = 24.0,
    ValueChanged<double>? onContextualPushOffsetChanged,
    ValueChanged<double>? onContextualPushPivotYChanged,
    ValueChanged<double>? onContextualPushPivotXChanged,
  }) async {
    // Drive contextual push if enabled
    if (useContextualPush && onContextualPushOffsetChanged != null) {
      final media = MediaQuery.of(context);
      final screenW = media.size.width;
      final screenH = media.size.height;

      double? triggerX = triggerPosition?.dx;
      double? triggerY = triggerPosition?.dy;

      // Compute closeness and emit pivotX
      double closeness = 1.0;
      if (triggerX != null && screenW > 0) {
        final nx = (triggerX / screenW).clamp(0.0, 1.0);
        onContextualPushPivotXChanged?.call(nx);
        closeness = isLeftSide ? (1.0 - nx) : nx;
      }

      // Edge-aligned push calculation
      final sheetW = size.calculateWidth(screenW);
      const edgeGap = 6.0;

      double minRequiredShift = 0.0;
      final coveredLeft = screenW - sheetW;
      if (isLeftSide) {
        // Align sheet's right edge (x = sheetW) to trigger's left edge + gap.
        final tLeft = triggerX; // interpret dx as left edge for left sheet
        if (tLeft != null) {
          final need = (sheetW + edgeGap) - tLeft;
          if (need > 0) minRequiredShift = need;
        }
      } else {
        // Align sheet's left edge (x = coveredLeft) to trigger's right edge - gap.
        final tRight = triggerX; // interpret dx as right edge for right sheet
        if (tRight != null) {
          final need = tRight - (coveredLeft - edgeGap);
          if (need > 0) minRequiredShift = need;
        }
      }

      final baseAmp = maxContextualPushOffset * closeness;
      final mag = minRequiredShift > 0 ? minRequiredShift : baseAmp;
      final signed = isLeftSide ? mag : -mag;
      onContextualPushOffsetChanged.call(signed);

      // Emit pivot Y if provided
      if (triggerY != null && screenH > 0) {
        final ny = (triggerY / screenH).clamp(0.0, 1.0);
        onContextualPushPivotYChanged?.call(ny);
      }
    }

    // Fallbacks for optional list-mode params when using customBuilder
    final void Function(T value) onChanged0 = onChanged ?? (_) {};
    final Widget Function(BuildContext, T, bool) itemBuilder0 =
        itemBuilder ?? (BuildContext _, T item, bool __) => Text('$item');

    final future = showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _SideSheetContent<T>(
          options: options,
          selectedValue: selectedValue,
          onChanged: onChanged0,
          itemBuilder: itemBuilder0,
          enableSearch: enableSearch,
          style: style,
          onSearch: onSearch,
          loadingWidget: loadingWidget,
          isLoading: isLoading,
          headerWidget: headerWidget,
          footerWidget: footerWidget,
          customBuilder: customBuilder,
          isLeftSide: isLeftSide,
          size: size,
          animation: animation,
          useSafeArea: useSafeArea,
          autoCloseOnSelect: autoCloseOnSelect,
        );
      },
    );

    await future.whenComplete(() {
      if (useContextualPush) {
        onContextualPushOffsetChanged?.call(0);
        onContextualPushPivotYChanged?.call(0.5);
        onContextualPushPivotXChanged?.call(0.5);
      }
    });
  }

  @override
  State<SideSheet<T>> createState() => _SideSheetState<T>();
}

class _SideSheetState<T> extends State<SideSheet<T>> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSideSheet() {
    _searchController.clear();

    if (widget.usePushBehavior) {
      // Use Scaffold drawer for push behavior
      if (widget.scaffoldKey == null) {
        throw FlutterError(
          'scaffoldKey is required when usePushBehavior is true.\n'
          'Please provide a GlobalKey<ScaffoldState> to the AdaptiveSelector.',
        );
      }

      // Open the appropriate drawer
      if (widget.isLeftSide) {
        widget.scaffoldKey!.currentState?.openDrawer();
      } else {
        widget.scaffoldKey!.currentState?.openEndDrawer();
      }
    } else {
      // Use overlay behavior (default)
      // Optionally trigger contextual push on the host page
      if (widget.useContextualPush &&
          widget.onContextualPushOffsetChanged != null) {
        final media = MediaQuery.of(context);
        final screenW = media.size.width;
        final screenH = media.size.height;

        // Determine trigger position and bounds.
        // Center comes from triggerPosition when provided; edges from RenderBox when available.
        double? triggerX;
        double? triggerY;
        double? triggerLeft;
        double? triggerRight;
        if (screenW > 0 && screenH > 0) {
          // Try to measure the widget's bounds for edge-aligned push calculation.
          final ro = context.findRenderObject();
          if (ro is RenderBox) {
            final topLeft = ro.localToGlobal(Offset.zero);
            final size = ro.size;
            triggerLeft = topLeft.dx;
            triggerRight = topLeft.dx + size.width;
            // Default center from measured bounds (if no explicit triggerPosition is provided).
            triggerX ??= (topLeft.dx + size.width / 2).clamp(0.0, screenW);
            triggerY ??= (topLeft.dy + size.height / 2).clamp(0.0, screenH);
          }
          // If caller provided explicit trigger center, use it for pivoting/anchoring.
          if (widget.triggerPosition != null) {
            triggerX = widget.triggerPosition!.dx;
            triggerY = widget.triggerPosition!.dy;
          }
        }

        // Compute closeness to the opening side: for left sheets, closeness increases
        // as the trigger is nearer the left edge; for right sheets the opposite.
        double closeness = 1.0;
        double? nx;
        if (triggerX != null && screenW > 0) {
          nx = (triggerX / screenW).clamp(0.0, 1.0);
          // Emit normalized pivot X (0..1) so host can anchor horizontal effects to the trigger
          widget.onContextualPushPivotXChanged?.call(nx);
          closeness = widget.isLeftSide ? (1.0 - nx) : nx;
        }

        // Compute side sheet width for edge-aligned push
        final sheetW = widget.size.calculateWidth(screenW);
        const edgeGap = 6.0; // small visual gap (4–8px recommended)

        double minRequiredShift =
            0.0; // absolute magnitude in pixels to align sheet edge to trigger edge
        final coveredLeft = screenW - sheetW;
        if (widget.isLeftSide) {
          // Align sheet's right edge (x = sheetW) to trigger's left edge + gap.
          final tLeft = triggerLeft ?? triggerX; // fallback if bounds missing
          if (tLeft != null) {
            final need = (sheetW + edgeGap) - tLeft;
            if (need > 0) minRequiredShift = need;
          }
        } else {
          // Align sheet's left edge (x = coveredLeft) to trigger's right edge - gap.
          final tRight = triggerRight ?? triggerX; // fallback if bounds missing
          if (tRight != null) {
            final need = tRight - (coveredLeft - edgeGap);
            if (need > 0) minRequiredShift = need;
          }
        }

        // Base subtle push amount scaled by closeness
        final baseAmp = widget.maxContextualPushOffset * closeness;

        // Prefer exact edge alignment when needed; otherwise apply subtle base push
        final double mag = minRequiredShift > 0 ? minRequiredShift : baseAmp;

        final signed = widget.isLeftSide ? mag : -mag;
        widget.onContextualPushOffsetChanged?.call(signed);

        // Compute and emit pivot Y (0..1) for rotational/hinge effects
        if (triggerY != null && screenH > 0) {
          final ny = (triggerY / screenH).clamp(0.0, 1.0);
          widget.onContextualPushPivotYChanged?.call(ny);
        }
      }

      final future = showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _SideSheetContent<T>(
            options: widget.options,
            selectedValue: widget.selectedValue,
            onChanged: widget.onChanged,
            itemBuilder: widget.itemBuilder,
            enableSearch: widget.enableSearch,
            style: widget.style,
            onSearch: widget.onSearch,
            loadingWidget: widget.loadingWidget,
            isLoading: widget.isLoading,
            headerWidget: widget.headerWidget,
            footerWidget: widget.footerWidget,
            customBuilder: widget.customBuilder,
            isLeftSide: widget.isLeftSide,
            size: widget.size,
            animation: animation,
            useSafeArea: widget.useSafeArea,
          );
        },
      );

      // Reset contextual push after the dialog is dismissed
      future.whenComplete(() {
        if (widget.useContextualPush) {
          widget.onContextualPushOffsetChanged?.call(0);
          widget.onContextualPushPivotYChanged?.call(0.5);
          widget.onContextualPushPivotXChanged?.call(0.5);
        }
      });
    }
  }

  /// Builds the drawer content for push behavior.
  /// This should be used in Scaffold.drawer or Scaffold.endDrawer.
  Widget buildDrawerContent() {
    return _SideSheetDrawerContent<T>(
      options: widget.options,
      selectedValue: widget.selectedValue,
      onChanged: widget.onChanged,
      itemBuilder: widget.itemBuilder,
      enableSearch: widget.enableSearch,
      style: widget.style,
      onSearch: widget.onSearch,
      loadingWidget: widget.loadingWidget,
      isLoading: widget.isLoading,
      headerWidget: widget.headerWidget,
      footerWidget: widget.footerWidget,
      size: widget.size,
      useSafeArea: widget.useSafeArea,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isLoading ? null : _showSideSheet,
      child: Container(
        padding:
            widget.style.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.style.backgroundColor ?? Colors.white,
          borderRadius: widget.style.borderRadius ?? BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : widget.selectedValue != null
                  ? DefaultTextStyle(
                      style:
                          widget.style.textStyle ??
                          TextStyle(
                            fontSize: 16,
                            color: widget.style.textColor ?? Colors.black87,
                          ),
                      child: widget.itemBuilder != null ? widget.itemBuilder!(
                        context,
                        widget.selectedValue as T,
                        true,
                      ) : SizedBox(),
                    )
                  : Text(
                      widget.hint ?? 'Select an option',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// Side sheet content widget with state management
class _SideSheetContent<T> extends StatefulWidget {
  final List<T>? options;
  final T? selectedValue;
  final void Function(T value)? onChanged;
  final Widget Function(BuildContext context, T item, bool isSelected)?
  itemBuilder;
  final bool enableSearch;
  final AdaptiveSelectorStyle style;
  final Future<List<T>> Function(String query)? onSearch;
  final Widget? loadingWidget;
  final bool isLoading;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final SideSheetCustomBuilder<T>? customBuilder;
  final bool isLeftSide;
  final SideSheetSize size;
  final Animation<double> animation;
  final bool useSafeArea;
  final bool autoCloseOnSelect;

  const _SideSheetContent({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    required this.enableSearch,
    required this.style,
    required this.isLeftSide,
    required this.size,
    required this.animation,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.headerWidget,
    this.footerWidget,
    this.customBuilder,
    this.useSafeArea = true,
    this.autoCloseOnSelect = true,
  });

  @override
  State<_SideSheetContent<T>> createState() => _SideSheetContentState<T>();
}

class _SideSheetContentState<T> extends State<_SideSheetContent<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredOptions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options ?? [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _filterOptions(String query) async {
    if (widget.onSearch != null) {
      // Async search
      setState(() {
        _isSearching = true;
      });

      try {
        final results = await widget.onSearch!(query);
        if (mounted) {
          setState(() {
            _filteredOptions = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    } else {
      // Sync search
      setState(() {
        _filteredOptions = SearchHelper.searchSync(widget.options ?? [], query);
      });
    }
  }

  Widget _buildSideSheetHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.style.dividerColor ?? Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Select an option',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.style.textColor ?? Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final bool showIcon = widget.style.showSearchIcon;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterOptions,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: showIcon
              ? (widget.style.searchIcon ?? const Icon(Icons.search))
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sheetWidth = widget.size.calculateWidth(screenWidth);

    // Build either custom content or the default column list content
    final Widget bodyContent;
    if (widget.customBuilder != null) {
      final custom = widget.customBuilder!(context, (value) {
        widget.onChanged!(value);
        if (widget.autoCloseOnSelect) Navigator.of(context).pop();
      }, () => Navigator.of(context).pop());
      bodyContent = custom;
    } else {
      bodyContent = Column(
        children: [
          _buildSideSheetHeader(context),
          if (widget.headerWidget != null) widget.headerWidget!,
          if (widget.enableSearch) _buildSearchField(),
          Expanded(
            child: _isSearching || widget.isLoading
                ? Center(
                    child: widget.loadingWidget ?? const DefaultLoadingWidget(),
                  )
                : _filteredOptions.isEmpty
                ? const Center(child: Text('No options available'))
                : ListView.builder(
                    itemCount: _filteredOptions.length,
                    itemBuilder: (context, index) {
                      final item = _filteredOptions[index];
                      final isSelected = item == widget.selectedValue;

                      return InkWell(
                        onTap: () {
                          widget.onChanged!(item);
                          if (widget.autoCloseOnSelect) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color: isSelected
                              ? (widget.style.selectedItemColor ??
                                    Colors.blue.shade50)
                              : null,
                          child: DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected
                                  ? (widget.style.selectedTextColor ??
                                        Colors.blue)
                                  : (widget.style.textColor ?? Colors.black87),
                            ),
                            child: widget.itemBuilder!(
                              context,
                              item,
                              isSelected,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (widget.footerWidget != null) widget.footerWidget!,
        ],
      );
    }

    // Wrap content in SafeArea if enabled
    final safeContent = widget.useSafeArea
        ? SafeArea(child: bodyContent)
        : bodyContent;

    // Wrap in Material with background (extends to full screen edges)
    final content = Material(
      color: widget.style.backgroundColor ?? Colors.white,
      child: SizedBox(width: sheetWidth, child: safeContent),
    );

    // Create the slide animation
    final slideAnimation =
        Tween<Offset>(
          begin: Offset(widget.isLeftSide ? -1.0 : 1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: widget.animation, curve: Curves.easeOutCubic),
        );

    return Align(
      alignment: widget.isLeftSide
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: SlideTransition(position: slideAnimation, child: content),
    );
  }
}

/// Drawer content widget for push behavior
class _SideSheetDrawerContent<T> extends StatefulWidget {
  final List<T>? options;
  final T? selectedValue;
  final void Function(T value)? onChanged;
  final Widget Function(BuildContext context, T item, bool isSelected)?
  itemBuilder;
  final bool enableSearch;
  final AdaptiveSelectorStyle style;
  final Future<List<T>> Function(String query)? onSearch;
  final Widget? loadingWidget;
  final bool isLoading;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final SideSheetSize size;
  final bool useSafeArea;

  const _SideSheetDrawerContent({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    required this.enableSearch,
    required this.style,
    required this.size,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.headerWidget,
    this.footerWidget,
    this.useSafeArea = true,
  });

  @override
  State<_SideSheetDrawerContent<T>> createState() =>
      _SideSheetDrawerContentState<T>();
}

class _SideSheetDrawerContentState<T>
    extends State<_SideSheetDrawerContent<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredOptions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options ?? [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _filterOptions(String query) async {
    if (widget.onSearch != null) {
      // Async search
      setState(() {
        _isSearching = true;
      });

      try {
        final results = await widget.onSearch!(query);
        if (mounted) {
          setState(() {
            _filteredOptions = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    } else {
      // Sync search
      setState(() {
        _filteredOptions = SearchHelper.searchSync(widget.options ?? [], query);
      });
    }
  }

  InputDecoration _buildSearchDecoration() {
    final bool showIcon = widget.style.showSearchIcon;
    final base =
        widget.style.searchFieldDecoration ??
        widget.style.searchDecoration ??
        InputDecoration(
          hintText: 'Search...',
          prefixIcon: showIcon
              ? (widget.style.searchIcon ?? const Icon(Icons.search))
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        );

    return base.copyWith(
      hintText: base.hintText ?? 'Search...',
      prefixIcon: showIcon
          ? (base.prefixIcon ??
              (widget.style.searchIcon ?? const Icon(Icons.search)))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate drawer width based on size
    final screenWidth = MediaQuery.of(context).size.width;
    double drawerWidth;
    switch (widget.size) {
      case SideSheetSize.small:
        drawerWidth = (screenWidth * 0.6).clamp(0, 280);
        break;
      case SideSheetSize.medium:
        drawerWidth = (screenWidth * 0.8).clamp(0, 400);
        break;
      case SideSheetSize.large:
        drawerWidth = (screenWidth * 0.9).clamp(0, 560);
        break;
      case SideSheetSize.full:
        drawerWidth = screenWidth;
        break;
    }

    final columnContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.headerWidget != null) widget.headerWidget!,
        if (widget.enableSearch)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: _buildSearchDecoration(),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    _filteredOptions = widget.options ?? [];
                  });
                } else {
                  _filterOptions(value);
                }
              },
            ),
          ),
        Expanded(
          child: _isSearching
              ? Center(
                  child: widget.loadingWidget ?? const DefaultLoadingWidget(),
                )
              : ListView.builder(
                  itemCount: _filteredOptions.length,
                  itemBuilder: (context, index) {
                    final item = _filteredOptions[index];
                    final isSelected = item == widget.selectedValue;

                    return InkWell(
                      onTap: () {
                        widget.onChanged!(item);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: isSelected
                            ? (widget.style.selectedItemColor ??
                                  Colors.blue.shade50)
                            : null,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? (widget.style.selectedTextColor ??
                                      Colors.blue)
                                : (widget.style.textColor ?? Colors.black87),
                          ),
                          child: widget.itemBuilder!(context, item, isSelected),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (widget.footerWidget != null) widget.footerWidget!,
      ],
    );

    // Wrap column content in SafeArea if enabled
    final safeContent = widget.useSafeArea
        ? SafeArea(child: columnContent)
        : columnContent;

    // Wrap in Material with background
    return Material(
      color: widget.style.backgroundColor ?? Colors.white,
      child: SizedBox(width: drawerWidth, child: safeContent),
    );
  }
}
