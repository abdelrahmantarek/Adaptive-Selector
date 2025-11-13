import 'package:flutter/material.dart';
import '../models/adaptive_selector_style.dart';
import '../utils/search_helper.dart';
import 'loading_widget.dart';

/// Mobile bottom sheet implementation for small screens.
class MobileBottomSheet<T> extends StatefulWidget {
  final List<T> options;
  final T? selectedValue;
  final void Function(T value) onChanged;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool enableSearch;
  final AdaptiveSelectorStyle style;
  final String? hint;
  final Future<List<T>> Function(String query)? onSearch;
  final Widget? loadingWidget;
  final bool isLoading;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final bool useSafeArea;

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
  });

  /// Programmatic API to open the bottom sheet overlay.
  /// If [customBuilder] is provided, list-mode parameters (options/onChanged/itemBuilder)
  /// can be omitted and you can render fully custom content. Use the `select(value)`
  /// to emit a selection and close the sheet, or `close()` to just close.
  static Future<void> openModal<T>({
    required BuildContext context,
    AdaptiveSelectorStyle style = const AdaptiveSelectorStyle(),
    // List-mode (optional when using customBuilder)
    List<T> options = const [],
    T? selectedValue,
    void Function(T value)? onChanged,
    Widget Function(BuildContext, T)? itemBuilder,
    bool enableSearch = false,
    String? hint,
    Future<List<T>> Function(String query)? onSearch,
    Widget? loadingWidget,
    bool isLoading = false,
    Widget? headerWidget,
    Widget? footerWidget,
    bool useSafeArea = true,
    // Fully custom content builder
    Widget Function(BuildContext, void Function(T), VoidCallback)?
    customBuilder,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        if (customBuilder != null) {
          void select(T v) {
            if (onChanged != null) onChanged(v);
            Navigator.of(ctx).pop();
          }

          void close() => Navigator.of(ctx).pop();
          final content = customBuilder(ctx, select, close);
          final safe = useSafeArea ? SafeArea(child: content) : content;
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
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
          itemBuilder != null && onChanged != null,
          'itemBuilder and onChanged must be provided when customBuilder is null',
        );
        return _BottomSheetContent<T>(
          options: options,
          selectedValue: selectedValue,
          onChanged: onChanged!,
          itemBuilder: itemBuilder!,
          enableSearch: enableSearch,
          style: style,
          onSearch: onSearch,
          loadingWidget: loadingWidget,
          isLoading: isLoading,
          headerWidget: headerWidget,
          footerWidget: footerWidget,
          useSafeArea: useSafeArea,
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
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool enableSearch;
  final AdaptiveSelectorStyle style;
  final Future<List<T>> Function(String query)? onSearch;
  final Widget? loadingWidget;
  final bool isLoading;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final bool useSafeArea;

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
  });

  @override
  State<_BottomSheetContent<T>> createState() => _BottomSheetContentState<T>();
}

class _BottomSheetContentState<T> extends State<_BottomSheetContent<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredOptions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
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
        final isSelected = item == widget.selectedValue;
        return _buildBottomSheetItem(item, isSelected);
      },
    );
  }

  Widget _buildBottomSheetItem(T item, bool isSelected) {
    return InkWell(
      onTap: () {
        widget.onChanged(item);
        Navigator.pop(context);
      },
      child: Container(
        height: widget.style.itemHeight ?? 56,
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
                child: widget.itemBuilder(context, item),
              ),
            ),
            if (isSelected)
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
