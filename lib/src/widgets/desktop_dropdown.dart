import 'package:flutter/material.dart';
import '../models/adaptive_selector_style.dart';
import '../utils/search_helper.dart';
import 'loading_widget.dart';

/// Desktop dropdown implementation for large screens with animations.
class DesktopDropdown<T> extends StatefulWidget {
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
  final Widget? dropdownHeaderWidget;
  final Widget? dropdownFooterWidget;

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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;

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
                          ),
                          child: SearchLoadingOverlay(
                            isLoading: _isSearching,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.dropdownHeaderWidget != null)
                                  widget.dropdownHeaderWidget!,
                                if (widget.enableSearch) _buildSearchField(),
                                Flexible(child: _buildOptionsList()),
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

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
          // Rebuild overlay with new results without closing it
          _rebuildOverlay();
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
      // Rebuild overlay with new results without closing it
      _rebuildOverlay();
    }
  }

  void _rebuildOverlay() {
    if (_isOpen && _overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
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
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _filteredOptions.length,
      itemBuilder: (context, index) {
        final item = _filteredOptions[index];
        final isSelected = item == widget.selectedValue;
        return _buildDropdownItem(item, isSelected);
      },
    );
  }

  Widget _buildDropdownItem(T item, bool isSelected) {
    return InkWell(
      onTap: () {
        widget.onChanged(item);
        _removeOverlay();
        _searchController.clear();
        setState(() {
          _filteredOptions = widget.options;
        });
      },
      child: Container(
        height: widget.style.itemHeight ?? 48,
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
          child: widget.itemBuilder(context, item),
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
              widget.style.dropdownIcon ??
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}
