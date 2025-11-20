import 'package:flutter/material.dart';
import '../models/adaptive_selector_style.dart';
import '../utils/search_helper.dart';
import 'loading_widget.dart';

/// Mobile bottom sheet implementation for small screens.
class MobileBottomSheet<T> extends StatefulWidget {
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
  final Widget? headerWidget;
  final Widget? footerWidget;
  final bool useSafeArea;
  // Multi-select support
  final List<T> selectedValues;
  final ValueChanged<List<T>>? onSelectionChanged;
  final Widget Function(BuildContext, List<T>)? selectedValuesBuilder;
  final bool isMultiSelect;

  const MobileBottomSheet({
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
    this.headerWidget,
    this.footerWidget,
    this.useSafeArea = true,
    // Multi-select
    this.selectedValues = const [],
    this.onSelectionChanged,
    this.selectedValuesBuilder,
    this.isMultiSelect = false,
  });

  /// Programmatic API to open the bottom sheet overlay.
  /// If [customBuilder] is provided, list-mode parameters (options/onChanged/itemBuilder)
  /// can be omitted and you can render fully custom content.
  ///
  /// The provided `select(value)` will:
  /// - In single-select mode: Call `onChanged(value)` if provided
  /// - In multi-select mode: Toggle the value in the selection list
  /// - Auto-close the sheet when [autoCloseOnSelect] is true (default in single-select, false in multi-select)
  ///
  /// The provided `close()` will always close only this bottom sheet instance.
  ///
  /// The [itemBuilder] callback receives three parameters:
  /// - BuildContext: the build context
  /// - T: the item to build
  /// - bool: whether the item is currently selected
  static Future<void> openModal<T>({
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
    // Whether select(value) should close the sheet automatically
    bool? autoCloseOnSelect,
    // Multi-select support
    List<T> selectedValues = const [],
    ValueChanged<List<T>>? onSelectionChanged,
    Widget Function(BuildContext, List<T>)? selectedValuesBuilder,
    bool isMultiSelect = false,
    // Fully custom content builder
    Widget Function(BuildContext, void Function(T), VoidCallback)?
    customBuilder,
  }) {
    // Capture the same Navigator used to open the sheet to guarantee correct close()
    final navigator = Navigator.of(context);

    // Default autoCloseOnSelect based on mode
    final effectiveAutoClose = autoCloseOnSelect ?? !isMultiSelect;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        if (customBuilder != null) {
          void select(T v) {
            if (onChanged != null) onChanged(v);
            if (effectiveAutoClose) navigator.pop();
          }

          void close() => navigator.pop();
          final content = customBuilder(ctx, select, close);
          final safe = useSafeArea ? SafeArea(child: content) : content;
          final screenHeight = MediaQuery.of(ctx).size.height;
          final sheetHeight = ((maxHeight ?? screenHeight * 0.75)).clamp(
            0.0,
            screenHeight,
          );
          return Container(
            height: sheetHeight,
            decoration: BoxDecoration(
              color: style.backgroundColor ?? Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: safe,
          );
        }

        assert(
          itemBuilder != null &&
              (onChanged != null || onSelectionChanged != null),
          'itemBuilder and (onChanged or onSelectionChanged) must be provided when customBuilder is null',
        );
        return _BottomSheetContent<T>(
          options: options,
          selectedValue: selectedValue,
          onChanged: onChanged ?? (_) {},
          itemBuilder: itemBuilder!,
          enableSearch: enableSearch,
          style: style,
          onSearch: onSearch,
          loadingWidget: loadingWidget,
          isLoading: isLoading,
          headerWidget: headerWidget,
          footerWidget: footerWidget,
          useSafeArea: useSafeArea,
          maxHeight: maxHeight,
          selectedValues: selectedValues,
          onSelectionChanged: onSelectionChanged,
          isMultiSelect: isMultiSelect,
          autoCloseOnSelect: effectiveAutoClose,
        );
      },
    );
  }

  @override
  State<MobileBottomSheet<T>> createState() => _MobileBottomSheetState<T>();
}

class _MobileBottomSheetState<T> extends State<MobileBottomSheet<T>> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBottomSheet() {
    _searchController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheetContent<T>(
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
        useSafeArea: widget.useSafeArea,
        selectedValues: widget.selectedValues,
        onSelectionChanged: widget.onSelectionChanged,
        isMultiSelect: widget.isMultiSelect,
        autoCloseOnSelect:
            !widget.isMultiSelect, // Default: don't auto-close in multi-select
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isLoading ? null : _showBottomSheet,
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
                  : widget.isMultiSelect
                  ? (widget.selectedValues.isNotEmpty
                        ? (widget.selectedValuesBuilder != null
                              ? widget.selectedValuesBuilder!(
                                  context,
                                  widget.selectedValues,
                                )
                              : Text(
                                  '${widget.selectedValues.length} selected',
                                  style: TextStyle(
                                    color:
                                        widget.style.textColor ??
                                        Colors.black87,
                                    fontSize: 16,
                                  ),
                                ))
                        : Text(
                            widget.hint ?? 'Select options',
                            style: TextStyle(
                              color: Colors.grey.shade600,
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
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet content widget with state management
class _BottomSheetContent<T> extends StatefulWidget {
  final List<T> options;
  final T? selectedValue;
  final void Function(T value) onChanged;
  final Widget Function(BuildContext context, T item, bool isSelected)
  itemBuilder;
  final bool enableSearch;
  final AdaptiveSelectorStyle style;
  final Future<List<T>> Function(String query)? onSearch;
  final Widget? loadingWidget;
  final bool isLoading;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final bool useSafeArea;
  final double? maxHeight;
  // Multi-select support
  final List<T> selectedValues;
  final ValueChanged<List<T>>? onSelectionChanged;
  final bool isMultiSelect;
  final bool autoCloseOnSelect;

  const _BottomSheetContent({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    required this.enableSearch,
    required this.style,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.headerWidget,
    this.footerWidget,
    this.useSafeArea = true,
    this.maxHeight,
    // Multi-select
    this.selectedValues = const [],
    this.onSelectionChanged,
    this.isMultiSelect = false,
    this.autoCloseOnSelect = true,
  });

  @override
  State<_BottomSheetContent<T>> createState() => _BottomSheetContentState<T>();
}

class _BottomSheetContentState<T> extends State<_BottomSheetContent<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredOptions = [];
  bool _isSearching = false;
  // Local working copy for multi-select to update UI immediately
  List<T> _localSelectedValues = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    if (widget.isMultiSelect) {
      _localSelectedValues = List<T>.from(widget.selectedValues);
    }
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
        _filteredOptions = SearchHelper.searchSync(widget.options, query);
      });
    }
  }

  Widget _buildBottomSheetHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Select an option',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.style.textColor ?? Colors.black87,
            ),
          ),
          IconButton(
            icon: widget.style.closeIcon ?? const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration:
            widget.style.searchDecoration ??
            InputDecoration(
              hintText: 'Search...',
              prefixIcon: widget.style.searchIcon ?? const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
        onChanged: _filterOptions,
      ),
    );
  }

  Widget _buildOptionsList() {
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
      itemCount: _filteredOptions.length,
      itemBuilder: (context, index) {
        final item = _filteredOptions[index];
        final isSelected = widget.isMultiSelect
            ? _localSelectedValues.contains(item)
            : item == widget.selectedValue;
        return _buildBottomSheetItem(item, isSelected);
      },
    );
  }

  Widget _buildBottomSheetItem(T item, bool isSelected) {
    return InkWell(
      onTap: () {
        if (widget.isMultiSelect) {
          setState(() {
            if (_localSelectedValues.contains(item)) {
              _localSelectedValues.remove(item);
            } else {
              _localSelectedValues.add(item);
            }
          });
          widget.onSelectionChanged?.call(List<T>.from(_localSelectedValues));
          if (widget.autoCloseOnSelect) {
            Navigator.pop(context);
          }
        } else {
          widget.onChanged(item);
          Navigator.pop(context);
        }
      },
      child: Container(
        constraints: BoxConstraints(minHeight: widget.style.itemHeight ?? 56),
        padding:
            widget.style.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.style.selectedItemColor ??
                    Colors.blue.withValues(alpha: 0.1))
              : null,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
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
            if (widget.isMultiSelect)
              Checkbox(
                value: isSelected,
                onChanged: null, // Handled by InkWell tap
                activeColor: widget.style.selectedTextColor ?? Colors.blue,
              )
            else if (isSelected)
              Icon(
                Icons.check,
                color: widget.style.selectedTextColor ?? Colors.blue,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the column content
    final columnContent = Column(
      children: [
        _buildBottomSheetHeader(context),
        if (widget.headerWidget != null) widget.headerWidget!,
        if (widget.enableSearch) _buildSearchField(),
        Expanded(
          child: SearchLoadingOverlay(
            isLoading: _isSearching,
            child: _buildOptionsList(),
          ),
        ),
        if (widget.footerWidget != null) widget.footerWidget!,
      ],
    );

    // Wrap column content in SafeArea if enabled
    final safeContent = widget.useSafeArea
        ? SafeArea(child: columnContent)
        : columnContent;

    // Wrap in Container with background (extends to full screen edges)
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = ((widget.maxHeight ?? screenHeight * 0.75)).clamp(
      0.0,
      screenHeight,
    );
    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: widget.style.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: safeContent,
    );
  }
}
