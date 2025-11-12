/// Defines the UI mode for the AdaptiveSelector widget.
///
/// This enum allows you to control whether the selector should automatically
/// adapt based on screen size, or force a specific UI presentation mode
/// regardless of screen size.
enum AdaptiveSelectorMode {
  /// Automatically switch between mobile and desktop UI based on screen size.
  ///
  /// This is the default behavior. The widget will use a bottom sheet on
  /// small screens (below the breakpoint) and a dropdown on large screens
  /// (at or above the breakpoint).
  automatic,

  /// Always use the mobile UI (bottom sheet) regardless of screen size.
  ///
  /// This forces the widget to always display options in a modal bottom sheet,
  /// even on large screens like tablets or desktops.
  ///
  /// Note: This is kept for backward compatibility. Consider using [bottomSheet]
  /// for new code.
  alwaysMobile,

  /// Always use the desktop UI (dropdown overlay) regardless of screen size.
  ///
  /// This forces the widget to always display options in a dropdown overlay,
  /// even on small screens like mobile phones.
  ///
  /// Note: This is kept for backward compatibility. Consider using [dropdown]
  /// for new code.
  alwaysDesktop,

  /// Bottom sheet presentation that slides up from the bottom.
  ///
  /// Same as [alwaysMobile] but with a more descriptive name.
  /// The sheet appears from the bottom edge of the screen with a backdrop overlay.
  bottomSheet,

  /// Dropdown overlay presentation that appears below the selector.
  ///
  /// Same as [alwaysDesktop] but with a more descriptive name.
  /// The dropdown appears below the selector widget.
  dropdown,

  /// Side sheet presentation that slides in from the left side.
  ///
  /// The sheet appears from the left edge of the screen with a backdrop overlay.
  /// Useful for navigation-style selections or when you want a drawer-like experience.
  /// Width is typically 80% of screen width or capped at 400px.
  leftSheet,

  /// Side sheet presentation that slides in from the right side.
  ///
  /// The sheet appears from the right edge of the screen with a backdrop overlay.
  /// Useful for settings-style selections or RTL layouts.
  /// Width is typically 80% of screen width or capped at 400px.
  rightSheet,
}
