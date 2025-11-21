import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/adaptive_selector_style.dart';
import '../utils/search_helper.dart';
import 'loading_widget.dart';

/// Desktop dropdown implementation for large screens with animations.
class DesktopDropdown<T> extends StatefulWidget {
  final List<T> options;
  final T? selectedValue;
  final void Function(T value) onChanged;
  final Widget Function(BuildContext context, T item, bool isSelected)
  itemBuilder;
  final bool enableSearch;
  final AdaptiveSelectorStyle style;
  final String? hint;
  final Future<List<T>> Function(String query)? onSearch;
  final Widget? loadingWidget;
  final bool isLoading;
  final Widget? dropdownHeaderWidget;
  final Widget? dropdownFooterWidget;
  // Multi-select support
  final List<T> selectedValues;
  final ValueChanged<List<T>>? onSelectionChanged;
  final Widget Function(BuildContext, List<T>)? selectedValuesBuilder;
  final bool isMultiSelect;

  /// Whether the dropdown should automatically close when an item is selected.
  ///
  /// Only applies to single-select mode. In multi-select mode the dropdown
  /// always stays open so the user can select multiple items.
  final bool autoCloseWhenSelect;

  const DesktopDropdown({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    required this.enableSearch,
    required this.style,
    this.hint,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.dropdownHeaderWidget,
    this.dropdownFooterWidget,
    // Multi-select
    this.selectedValues = const [],
    this.onSelectionChanged,
    this.selectedValuesBuilder,
    this.isMultiSelect = false,
    this.autoCloseWhenSelect = true,
  });

  @override
  State<DesktopDropdown<T>> createState() => _DesktopDropdownState<T>();
}

class _DesktopDropdownState<T> extends State<DesktopDropdown<T>>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredOptions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  bool _isSearching = false;
  // Local working copy for multi-select to update UI immediately
  List<T> _localSelectedValues = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    if (widget.isMultiSelect) {
      _localSelectedValues = List<T>.from(widget.selectedValues);
    }

    // Initialize animation controller
    _animationController = AnimationController(
      duration: widget.style.animationDuration,
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Slide animation
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void didUpdateWidget(DesktopDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options != oldWidget.options) {
      setState(() {
        _filteredOptions = widget.options;
      });
    }
    if (widget.isMultiSelect &&
        !listEquals(widget.selectedValues, _localSelectedValues)) {
      setState(() {
        _localSelectedValues = List<T>.from(widget.selectedValues);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlayImmediate();
    _animationController.dispose();
    super.dispose();
  }

  void _removeOverlayImmediate() {
    if (_isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    }
  }

  void _removeOverlay() {
    if (_isOpen && mounted) {
      _animationController.reverse().then((_) {
        if (mounted) {
          _overlayEntry?.remove();
          _overlayEntry = null;
          _isOpen = false;
        }
      });
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (widget.isMultiSelect) {
      // Each time the dropdown opens, sync the local selection state with the
      // latest external selectedValues to avoid stale selections.
      _localSelectedValues = List<T>.from(widget.selectedValues);
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
    _animationController.forward();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 5),
                child: GestureDetector(
                  onTap: () {
                    // Prevent closing when tapping inside the dropdown
                  },
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Material(
                        elevation: 4,
                        borderRadius:
                            widget.style.borderRadius ??
                            BorderRadius.circular(8),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          decoration: BoxDecoration(
                            color: widget.style.backgroundColor ?? Colors.white,
                            borderRadius:
                                widget.style.borderRadius ??
                                BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.style.borderColor ?? Colors.grey,
                            ),
                          ),
                          child: SearchLoadingOverlay(
                            isLoading: _isSearching,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.dropdownHeaderWidget != null)
                                  widget.dropdownHeaderWidget!,
                                if (widget.enableSearch) buildSearchField(),
                                Flexible(child: buildOptionsList()),
                                if (widget.dropdownFooterWidget != null)
                                  widget.dropdownFooterWidget!,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchField() {
    final base =
        widget.style.searchFieldDecoration ??
        widget.style.searchDecoration ??
        InputDecoration(
          hintText: 'Search...',
          prefixIcon: widget.style.searchIcon ?? const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        );

    final decoration = base.copyWith(
      hintText: base.hintText ?? 'Search...',
      prefixIcon:
          base.prefixIcon ??
          (widget.style.searchIcon ?? const Icon(Icons.search)),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: decoration,
        onChanged: filterOptions,
      ),
    );
  }

  Future<void> filterOptions(String query) async {
    if (widget.onSearch != null) {
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
          rebuildOverlay();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    } else {
      setState(() {
        _filteredOptions = SearchHelper.searchSync(widget.options, query);
      });
      rebuildOverlay();
    }
  }

  void rebuildOverlay() {
    if (_isOpen && _overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  Widget buildOptionsList() {
    if (widget.isLoading) {
      return widget.loadingWidget ?? const DefaultLoadingWidget();
    }

    if (_filteredOptions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No options found')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _filteredOptions.length,
      itemBuilder: (context, index) {
        final item = _filteredOptions[index];
        final bool isSelected = widget.isMultiSelect
            ? _localSelectedValues.contains(item)
            : item == widget.selectedValue;
        return buildDropdownItem(item, isSelected);
      },
    );
  }

  Widget buildDropdownItem(T item, bool isSelected) {
    return InkWell(
      onTap: () {
        if (widget.isMultiSelect) {
          if (_localSelectedValues.contains(item)) {
            _localSelectedValues.remove(item);
          } else {
            _localSelectedValues.add(item);
          }
          setState(() {});
          _overlayEntry?.markNeedsBuild();
          widget.onSelectionChanged?.call(List<T>.from(_localSelectedValues));
        } else {
          widget.onChanged(item);
          if (widget.autoCloseWhenSelect) {
            _removeOverlay();
          }
          _searchController.clear();
          setState(() {
            _filteredOptions = widget.options;
          });
        }
      },
      child: Container(
        constraints: BoxConstraints(minHeight: widget.style.itemHeight ?? 48),
        padding:
            widget.style.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.style.selectedItemColor ??
                    Colors.blue.withValues(alpha: 0.1))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: DefaultTextStyle(
                style:
                    (isSelected
                        ? widget.style.selectedTextStyle
                        : widget.style.textStyle) ??
                    TextStyle(
                      color: isSelected
                          ? (widget.style.selectedTextColor ?? Colors.blue)
                          : (widget.style.textColor ?? Colors.black87),
                      fontSize: 16,
                    ),
                child: widget.itemBuilder(context, item, isSelected),
              ),
            ),
            if (widget.isMultiSelect) ...[
              const SizedBox(width: 8),
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20,
                color: isSelected
                    ? (widget.style.selectedTextColor ?? Colors.blue)
                    : (widget.style.textColor ?? Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: widget.isLoading ? null : _toggleDropdown,
        child: Container(
          padding:
              widget.style.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.style.backgroundColor ?? Colors.white,
            borderRadius: widget.style.borderRadius ?? BorderRadius.circular(8),
            border: Border.all(
              color: widget.style.borderColor ?? Colors.grey.shade300,
            ),
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
                    : widget.isMultiSelect
                    ? (widget.selectedValuesBuilder != null
                          ? DefaultTextStyle(
                              style:
                                  widget.style.textStyle ??
                                  TextStyle(
                                    color:
                                        widget.style.textColor ??
                                        Colors.black87,
                                    fontSize: 16,
                                  ),
                              child: widget.selectedValuesBuilder!(
                                context,
                                _localSelectedValues,
                              ),
                            )
                          : Text(
                              _localSelectedValues.isNotEmpty
                                  ? '${_localSelectedValues.length} selected'
                                  : (widget.hint ?? 'Select options'),
                              style: TextStyle(
                                color: _localSelectedValues.isNotEmpty
                                    ? (widget.style.textColor ?? Colors.black87)
                                    : Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ))
                    : widget.selectedValue != null
                    ? DefaultTextStyle(
                        style:
                            widget.style.textStyle ??
                            TextStyle(
                              color: widget.style.textColor ?? Colors.black87,
                              fontSize: 16,
                            ),
                        child: widget.itemBuilder(
                          context,
                          widget.selectedValue as T,
                          true,
                        ),
                      )
                    : Text(
                        widget.hint ?? 'Select an option',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
              ),
              widget.style.dropdownIcon ??
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}

/// Programmatic overlay API for desktop-style dropdown.
class DesktopDropdownOverlay {
  DesktopDropdownOverlay._();

  static Future<void> openOverlay<T>({
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
    // Multi-select support
    List<T> selectedValues = const [],
    ValueChanged<List<T>>? onSelectionChanged,
    bool isMultiSelect = false,
    // Fully custom content builder
    Widget Function(BuildContext, void Function(T), VoidCallback)?
    customBuilder,
    // Whether select(value) should auto-close (applies to customBuilder and list)
    bool autoCloseOnSelect = true,
    // Anchoring
    LayerLink? anchorLink,
    Rect? anchorRect,
    double panelWidth =
        0, // 0 => derive from anchorRect.width or fallback to 300
    double anchorHeight = 40,
    double verticalOffset = 5,
  }) {
    final overlay = Overlay.of(context);

    final completer = Completer<void>();
    late OverlayEntry entry;

    void close() {
      entry.remove();
      if (!completer.isCompleted) completer.complete();
    }

    entry = OverlayEntry(
      builder: (ctx) => _ProgrammaticDropdownOverlay<T>(
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
        anchorLink: anchorLink,
        anchorRect: anchorRect,
        panelWidth: panelWidth,
        anchorHeight: anchorHeight,
        verticalOffset: verticalOffset,
        onClose: close,
      ),
    );

    overlay.insert(entry);
    return completer.future;
  }
}

class _ProgrammaticDropdownOverlay<T> extends StatefulWidget {
  final AdaptiveSelectorStyle style;
  final List<T> options;
  final T? selectedValue;
  final void Function(T value)? onChanged;
  final Widget Function(BuildContext, T, bool)? itemBuilder;
  final bool enableSearch;
  final String? hint;
  final Future<List<T>> Function(String query)? onSearch;
  final Widget? loadingWidget;
  final bool isLoading;
  final Widget? headerWidget;
  final Widget? footerWidget;
  // Multi-select support
  final List<T> selectedValues;
  final ValueChanged<List<T>>? onSelectionChanged;
  final bool isMultiSelect;

  final Widget Function(BuildContext, void Function(T), VoidCallback)?
  customBuilder;
  final bool autoCloseOnSelect;
  final LayerLink? anchorLink;
  final Rect? anchorRect;
  final double panelWidth;
  final double anchorHeight;
  final double verticalOffset;
  final VoidCallback onClose;

  const _ProgrammaticDropdownOverlay({
    required this.style,
    required this.options,
    required this.selectedValue,
    this.onChanged,
    this.itemBuilder,
    required this.enableSearch,
    this.hint,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.headerWidget,
    this.footerWidget,
    // Multi-select
    this.selectedValues = const [],
    this.onSelectionChanged,
    this.isMultiSelect = false,
    this.customBuilder,
    this.autoCloseOnSelect = true,
    this.anchorLink,
    this.anchorRect,
    this.panelWidth = 0,
    this.anchorHeight = 40,
    this.verticalOffset = 5,
    required this.onClose,
  });

  @override
  State<_ProgrammaticDropdownOverlay<T>> createState() =>
      _ProgrammaticDropdownOverlayState<T>();
}

class _ProgrammaticDropdownOverlayState<T>
    extends State<_ProgrammaticDropdownOverlay<T>>
    with SingleTickerProviderStateMixin {
  late List<T> filteredOptions;
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  // Local working copy for multi-select selections
  List<T> selectedValues = [];

  final GlobalKey panelKey = GlobalKey();
  bool placeAboveFollower = false; // false => below, true => above
  double dxFollower = 0; // horizontal correction to keep panel within screen
  double linkMaxHeight = 300; // dynamic max height when using LayerLink

  void scheduleFlipCheck() {
    // After each build, recompute placement for LayerLink mode to avoid overflow
    WidgetsBinding.instance.addPostFrameCallback((_) => checkFlipIfNeeded());
  }

  void checkFlipIfNeeded() {
    if (widget.anchorLink == null) return; // Only relevant for LayerLink mode
    final ctx = panelKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;

    final screenSize = MediaQuery.of(context).size;
    final topLeft = box.localToGlobal(Offset.zero);
    final size = box.size;

    // Infer the anchor's global top/bottom using current orientation
    late double anchorTopY;
    late double anchorBottomY;
    if (placeAboveFollower) {
      final panelBottom = topLeft.dy + size.height;
      anchorTopY = panelBottom + widget.verticalOffset;
      anchorBottomY = anchorTopY + widget.anchorHeight;
    } else {
      final panelTop = topLeft.dy;
      anchorBottomY = panelTop - widget.verticalOffset;
      anchorTopY = anchorBottomY - widget.anchorHeight;
    }

    // Compute available spaces (account for small edge padding)
    const double edgePadding = 8.0;
    final double spaceBelow =
        (screenSize.height - anchorBottomY) -
        widget.verticalOffset -
        edgePadding;
    final double spaceAbove = anchorTopY - widget.verticalOffset - edgePadding;

    // Decide desired orientation and max height to fit
    final bool desiredPlaceAbove = spaceAbove > spaceBelow;
    final double chosenSpace = desiredPlaceAbove ? spaceAbove : spaceBelow;
    final double newMaxHeight = chosenSpace.clamp(50.0, 300.0);

    // Horizontal correction to keep within screen bounds
    final double left = topLeft.dx;
    final double maxLeft = screenSize.width - size.width - edgePadding;
    // Ensure min <= max for clamp, otherwise use the constrained value directly
    final double clampedLeft = maxLeft >= edgePadding
        ? left.clamp(edgePadding, maxLeft)
        : edgePadding;
    final double newDx = dxFollower + (clampedLeft - left);

    bool changed = false;
    if (desiredPlaceAbove != placeAboveFollower) {
      placeAboveFollower = desiredPlaceAbove;
      changed = true;
    }
    if ((newMaxHeight - linkMaxHeight).abs() > 0.5) {
      linkMaxHeight = newMaxHeight;
      changed = true;
    }
    if ((newDx - dxFollower).abs() > 0.5) {
      dxFollower = newDx;
      changed = true;
    }

    if (changed && mounted) {
      setState(() {});
      // Re-validate next frame to ensure stability after changes
      WidgetsBinding.instance.addPostFrameCallback((_) => checkFlipIfNeeded());
    }
  }

  @override
  void initState() {
    super.initState();
    filteredOptions = widget.options;
    animationController = AnimationController(
      duration: widget.style.animationDuration,
      vsync: this,
    );
    if (widget.isMultiSelect) {
      selectedValues = List<T>.from(widget.selectedValues);
    }

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );
    slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    // Start animation on first frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => animationController.forward(),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    animationController.dispose();
    super.dispose();
  }

  Future<void> filterOptions(String query) async {
    if (widget.onSearch != null) {
      setState(() => isSearching = true);
      try {
        final results = await widget.onSearch!(query);
        if (!mounted) return;
        setState(() {
          filteredOptions = results;
          isSearching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => isSearching = false);
      }
    } else {
      setState(() {
        filteredOptions = SearchHelper.searchSync(widget.options, query);
      });
    }
  }

  Widget buildSearchField() {
    final base =
        widget.style.searchFieldDecoration ??
        widget.style.searchDecoration ??
        InputDecoration(
          hintText: widget.hint ?? 'Search...',
          prefixIcon: widget.style.searchIcon ?? const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        );

    final decoration = base.copyWith(
      hintText: base.hintText ?? (widget.hint ?? 'Search...'),
      prefixIcon:
          base.prefixIcon ??
          (widget.style.searchIcon ?? const Icon(Icons.search)),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: decoration,
        onChanged: filterOptions,
      ),
    );
  }

  Widget buildOptionsList() {
    if (widget.isLoading) {
      return widget.loadingWidget ?? const DefaultLoadingWidget();
    }
    if (filteredOptions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No options found')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: filteredOptions.length,
      itemBuilder: (context, index) {
        final item = filteredOptions[index];
        final bool isSelected = widget.isMultiSelect
            ? selectedValues.contains(item)
            : item == widget.selectedValue;
        return InkWell(
          onTap: () {
            if (widget.isMultiSelect) {
              setState(() {
                if (selectedValues.contains(item)) {
                  selectedValues.remove(item);
                } else {
                  selectedValues.add(item);
                }
              });
              widget.onSelectionChanged?.call(List<T>.from(selectedValues));
              searchController.clear();
              if (widget.autoCloseOnSelect) widget.onClose();
            } else {
              widget.onChanged?.call(item);
              searchController.clear();
              if (widget.autoCloseOnSelect) widget.onClose();
            }
          },
          child: Container(
            constraints: null,
            height: null,
            padding:
                widget.style.padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (widget.style.selectedItemColor ??
                        Colors.blue.withValues(alpha: 0.1))
                  : null,
            ),
            child: DefaultTextStyle(
              style:
                  (isSelected
                      ? widget.style.selectedTextStyle
                      : widget.style.textStyle) ??
                  TextStyle(
                    color: isSelected
                        ? (widget.style.selectedTextColor ?? Colors.blue)
                        : (widget.style.textColor ?? Colors.black87),
                    fontSize: 16,
                  ),
              child: Row(
                children: [
                  Expanded(
                    child: widget.itemBuilder != null
                        ? widget.itemBuilder!(context, item, isSelected)
                        : Text('$item'),
                  ),
                  if (widget.isMultiSelect) ...[
                    const SizedBox(width: 8),
                    Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected
                          ? (widget.style.selectedTextColor ?? Colors.blue)
                          : (widget.style.textColor ?? Colors.black54),
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final Rect? rect = widget.anchorRect;
    final double width = widget.panelWidth > 0
        ? widget.panelWidth
        : (rect?.width ?? 300);

    // Determine constraints and orientation for rect anchoring
    const double edgePadding = 8.0;
    double maxHeightRect = 300;
    bool placeBelowRect = true;
    if (rect != null) {
      final double spaceBelow =
          (screenSize.height - rect.bottom) -
          widget.verticalOffset -
          edgePadding;
      final double spaceAbove = rect.top - widget.verticalOffset - edgePadding;
      placeBelowRect = spaceBelow >= spaceAbove;
      final double chosenSpace = placeBelowRect ? spaceBelow : spaceAbove;
      final double safeSpace = chosenSpace;
      maxHeightRect = safeSpace.clamp(50.0, 300.0).toDouble();
    }

    final double leftForRect = rect != null
        ? rect.left.clamp(edgePadding, screenSize.width - width - edgePadding)
        : 0.0;

    final double effectiveMaxHeight = widget.anchorLink != null
        ? linkMaxHeight
        : maxHeightRect;

    final panel = FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Material(
          key: panelKey,
          elevation: 4,
          borderRadius: widget.style.borderRadius ?? BorderRadius.circular(8),
          child: Container(
            width: width,
            constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
            decoration: BoxDecoration(
              color: widget.style.backgroundColor ?? Colors.white,
              borderRadius:
                  widget.style.borderRadius ?? BorderRadius.circular(8),
              border: Border.all(
                color: widget.style.borderColor ?? Colors.grey,
              ),
            ),
            child: widget.customBuilder != null
                ? Builder(
                    builder: (ctx) {
                      void select(T v) {
                        if (widget.isMultiSelect) {
                          setState(() {
                            if (selectedValues.contains(v)) {
                              selectedValues.remove(v);
                            } else {
                              selectedValues.add(v);
                            }
                          });
                          widget.onSelectionChanged?.call(
                            List<T>.from(selectedValues),
                          );
                          if (widget.autoCloseOnSelect) widget.onClose();
                        } else {
                          widget.onChanged?.call(v);
                          if (widget.autoCloseOnSelect) widget.onClose();
                        }
                      }

                      return widget.customBuilder!(ctx, select, widget.onClose);
                    },
                  )
                : SearchLoadingOverlay(
                    isLoading: isSearching,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.headerWidget != null) widget.headerWidget!,
                        if (widget.enableSearch) buildSearchField(),
                        Flexible(child: buildOptionsList()),
                        if (widget.footerWidget != null) widget.footerWidget!,
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );

    // Recompute placement for LayerLink (runs after build)
    scheduleFlipCheck();

    return GestureDetector(
      onTap: widget.onClose,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          if (widget.anchorLink != null)
            Positioned.fill(
              child: CompositedTransformFollower(
                link: widget.anchorLink!,
                showWhenUnlinked: false,
                targetAnchor: placeAboveFollower
                    ? Alignment.topLeft
                    : Alignment.bottomLeft,
                followerAnchor: placeAboveFollower
                    ? Alignment.bottomLeft
                    : Alignment.topLeft,
                offset: Offset(
                  dxFollower,
                  placeAboveFollower
                      ? -widget.verticalOffset
                      : widget.verticalOffset,
                ),
                child: GestureDetector(onTap: () {}, child: panel),
              ),
            )
          else
            Positioned(
              left: leftForRect,
              top: (rect != null && placeBelowRect)
                  ? (rect.bottom + widget.verticalOffset)
                  : null,
              bottom: (rect != null && !placeBelowRect)
                  ? ((screenSize.height - rect.top) + widget.verticalOffset)
                  : null,
              width: width,
              child: GestureDetector(onTap: () {}, child: panel),
            ),
        ],
      ),
    );
  }
}
