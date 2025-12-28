import 'package:flutter/material.dart';
import '../models/adaptive_selector_style.dart';
import '../models/anchor_position.dart';
import 'loading_widget.dart';

/// Anchored panel implementation that positions itself relative to an anchor widget.
///
/// Uses [CompositedTransformFollower] to position the panel next to the anchor
/// widget specified by [anchorLink]. Automatically adjusts position based on
/// available screen space.
class AnchoredPanel<T> extends StatefulWidget {
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
  final LayerLink anchorLink;
  final AnchorPosition anchorPosition;
  final Offset anchorOffset;
  final double panelWidth;

  const AnchoredPanel({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
    required this.anchorLink,
    this.enableSearch = false,
    this.style = const AdaptiveSelectorStyle(),
    this.hint,
    this.onSearch,
    this.loadingWidget,
    this.isLoading = false,
    this.headerWidget,
    this.footerWidget,
    this.anchorPosition = AnchorPosition.auto,
    this.anchorOffset = const Offset(8, 0),
    this.panelWidth = 300,
  });

  @override
  State<AnchoredPanel<T>> createState() => AnchoredPanelState<T>();
}

class AnchoredPanelState<T> extends State<AnchoredPanel<T>>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredOptions = [];
  OverlayEntry? _overlayEntry;
  static bool isOpen = false;
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options ?? [];

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(AnchoredPanel<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      setState(() {
        _filteredOptions = widget.options ?? [];
      });
    }
    // If the anchor link changed, close the overlay to prevent LayerLink errors
    if (oldWidget.anchorLink != widget.anchorLink && isOpen) {
      _removeOverlayImmediate();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    // Close overlay on hot reload to prevent LayerLink errors
    if (isOpen) {
      _removeOverlayImmediate();
    }
  }

  @override
  void deactivate() {
    // Close overlay when widget is removed from tree to prevent LayerLink errors
    if (isOpen) {
      _removeOverlayImmediate();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlayImmediate();
    _animationController.dispose();
    super.dispose();
  }

  void _removeOverlayImmediate() {
    if (isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      isOpen = false;
    }
  }

  void _removeOverlay() {
    if (isOpen && mounted) {
      _animationController.reverse().then((_) {
        if (mounted) {
          _overlayEntry?.remove();
          _overlayEntry = null;
          isOpen = false;
        }
      });
    }
  }

  void _togglePanel() {
    if (isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    isOpen = true;
    _animationController.forward();
  }



  /// Calculates the best position for the panel based on available space.
  _PositionData _calculatePosition(BuildContext context, RenderBox anchorBox) {
    final anchorSize = anchorBox.size;
    final anchorPosition = anchorBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    // Panel dimensions
    const maxPanelHeight = 400.0;
    final panelWidth = widget.panelWidth;

    AnchorPosition finalPosition = widget.anchorPosition;
    Offset offset = widget.anchorOffset;

    // Auto-detect best position if set to auto
    if (widget.anchorPosition == AnchorPosition.auto) {
      final spaceRight =
          screenSize.width - (anchorPosition.dx + anchorSize.width);
      final spaceLeft = anchorPosition.dx;
      final spaceBottom =
          screenSize.height - (anchorPosition.dy + anchorSize.height);

      // Choose position with most space (priority: right, left, bottom, top)
      if (spaceRight >= panelWidth) {
        finalPosition = AnchorPosition.right;
      } else if (spaceLeft >= panelWidth) {
        finalPosition = AnchorPosition.left;
      } else if (spaceBottom >= maxPanelHeight) {
        finalPosition = AnchorPosition.bottom;
      } else {
        finalPosition = AnchorPosition.top;
      }
    }

    // Calculate offset based on final position
    switch (finalPosition) {
      case AnchorPosition.right:
        // Check if there's enough space on the right
        final spaceRight =
            screenSize.width - (anchorPosition.dx + anchorSize.width);
        if (spaceRight < panelWidth) {
          // Flip to left
          finalPosition = AnchorPosition.left;
          offset = Offset(
            -panelWidth - widget.anchorOffset.dx,
            widget.anchorOffset.dy,
          );
        } else {
          offset = Offset(
            anchorSize.width + widget.anchorOffset.dx,
            widget.anchorOffset.dy,
          );
        }
        break;

      case AnchorPosition.left:
        // Check if there's enough space on the left
        if (anchorPosition.dx < panelWidth) {
          // Flip to right
          finalPosition = AnchorPosition.right;
          offset = Offset(
            anchorSize.width + widget.anchorOffset.dx,
            widget.anchorOffset.dy,
          );
        } else {
          offset = Offset(
            -panelWidth - widget.anchorOffset.dx,
            widget.anchorOffset.dy,
          );
        }
        break;

      case AnchorPosition.bottom:
        // Check if there's enough space below
        final spaceBottom =
            screenSize.height - (anchorPosition.dy + anchorSize.height);
        if (spaceBottom < maxPanelHeight) {
          // Flip to top
          finalPosition = AnchorPosition.top;
          offset = Offset(
            widget.anchorOffset.dx,
            -maxPanelHeight - widget.anchorOffset.dy,
          );
        } else {
          offset = Offset(
            widget.anchorOffset.dx,
            anchorSize.height + widget.anchorOffset.dy,
          );
        }
        break;

      case AnchorPosition.top:
        // Check if there's enough space above
        if (anchorPosition.dy < maxPanelHeight) {
          // Flip to bottom
          finalPosition = AnchorPosition.bottom;
          offset = Offset(
            widget.anchorOffset.dx,
            anchorSize.height + widget.anchorOffset.dy,
          );
        } else {
          offset = Offset(
            widget.anchorOffset.dx,
            -maxPanelHeight - widget.anchorOffset.dy,
          );
        }
        break;

      case AnchorPosition.auto:
        // Already handled above
        break;
    }

    return _PositionData(
      position: finalPosition,
      offset: offset,
      panelWidth: panelWidth,
    );
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      maintainState: false,
      builder: (context) {
        // Get anchor box for position calculation
        final anchorBox = context.findRenderObject() as RenderBox?;
        final positionData = anchorBox != null
            ? _calculatePosition(context, anchorBox)
            : _PositionData(
                position: AnchorPosition.right,
                offset: widget.anchorOffset,
                panelWidth: widget.panelWidth,
              );

        return GestureDetector(
          onTap: _removeOverlay,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                width: positionData.panelWidth,
                child: CompositedTransformFollower(
                  link: widget.anchorLink,
                  showWhenUnlinked: false,
                  offset: positionData.offset,
                  child: GestureDetector(
                    onTap: () {
                      // Prevent closing when tapping inside the panel
                    },
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        alignment: _getScaleAlignment(positionData.position),
                        child: Material(
                          elevation: 8,
                          borderRadius:
                              widget.style.borderRadius ??
                              BorderRadius.circular(12),
                          shadowColor: Colors.black.withValues(alpha: 0.2),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 400),
                            decoration: BoxDecoration(
                              color:
                                  widget.style.backgroundColor ?? Colors.white,
                              borderRadius:
                                  widget.style.borderRadius ??
                                  BorderRadius.circular(12),
                            ),
                            child: _buildPanelContent(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Alignment _getScaleAlignment(AnchorPosition position) {
    switch (position) {
      case AnchorPosition.right:
        return Alignment.centerLeft;
      case AnchorPosition.left:
        return Alignment.centerRight;
      case AnchorPosition.bottom:
        return Alignment.topCenter;
      case AnchorPosition.top:
        return Alignment.bottomCenter;
      case AnchorPosition.auto:
        return Alignment.center;
    }
  }

  Widget _buildPanelContent() {
    return SearchLoadingOverlay(
      isLoading: _isSearching,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.headerWidget != null) widget.headerWidget!,
          if (widget.enableSearch) _buildSearchField(),
          Flexible(child: _buildOptionsList()),
          if (widget.footerWidget != null) widget.footerWidget!,
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onChanged: _filterOptions,
        decoration: _buildSearchDecoration(),
      ),
    );
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
            horizontal: 12,
            vertical: 8,
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

  void _filterOptions(String query) async {
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
      // Synchronous search
      setState(() {
        if (query.isEmpty) {
          _filteredOptions = widget.options ?? [];
        } else {
          final lowerQuery = query.toLowerCase();
          _filteredOptions = widget.options!.where((item) {
            // Convert item to string using itemBuilder
            final itemText = widget
                .itemBuilder!(context, item, false)
                .toString()
                .toLowerCase();
            return itemText.contains(lowerQuery);
          }).toList();
        }
      });
    }

    // Rebuild overlay to update content
    _overlayEntry?.markNeedsBuild();
  }

  Widget _buildOptionsList() {
    if (widget.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: widget.loadingWidget ?? const DefaultLoadingWidget(),
      );
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
        return _buildPanelItem(item, isSelected);
      },
    );
  }

  Widget _buildPanelItem(T item, bool isSelected) {
    return InkWell(
      onTap: () {
        widget.onChanged!(item);
        _removeOverlay();
        _searchController.clear();
        setState(() {
          _filteredOptions = widget.options ?? [];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected
            ? (widget.style.selectedItemColor ?? Colors.blue.shade50)
            : null,
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 15,
            color: isSelected
                ? (widget.style.selectedTextColor ?? Colors.blue)
                : (widget.style.textColor ?? Colors.black87),
          ),
          child: widget.itemBuilder!(context, item, isSelected),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: widget.anchorLink,
      child: InkWell(
        onTap: widget.isLoading ? null : _togglePanel,
        child: Container(
          padding:
              widget.style.padding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.style.backgroundColor ?? Colors.white,
            borderRadius: widget.style.borderRadius ?? BorderRadius.circular(8),
            border: Border.all(
              color: isOpen
                  ? (widget.style.selectedItemColor ?? Colors.blue.shade300)
                  : (widget.style.borderColor ?? Colors.grey.shade300),
              width: isOpen ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : widget.selectedValue != null
                  ? DefaultTextStyle(
                      style:
                          widget.style.textStyle ??
                          TextStyle(
                            color: widget.style.textColor ?? Colors.black87,
                            fontSize: 14,
                          ),
                      child: widget.itemBuilder!(
                        context,
                        widget.selectedValue as T,
                        true,
                      ),
                    )
                  : Text(
                      widget.hint ?? 'Select',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
              const SizedBox(width: 8),
              Icon(
                isOpen ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper class to store position calculation results.
class _PositionData {
  final AnchorPosition position;
  final Offset offset;
  final double panelWidth;

  _PositionData({
    required this.position,
    required this.offset,
    required this.panelWidth,
  });
}
