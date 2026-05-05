import 'package:flutter/material.dart';

class MyCustomDecorations {
  /// Private constructor to prevent instantiation
  MyCustomDecorations._();

  /// Standard Input Decoration for TextFields and TextFormFields
  static InputDecoration inputDecoration(
    BuildContext context,
    String hint, {
    Color? primaryColor,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    final theme = Theme.of(context);
    final activeColor = primaryColor ?? theme.colorScheme.primary;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: theme.colorScheme.surface, // Adapts to light/dark mode
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: activeColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
    );
  }

  /// Standard Dropdown Decoration
  /// Inherits from inputDecoration but can be customized further if needed.
  static InputDecoration dropdownDecoration(
    BuildContext context,
    String hint, {
    Color? primaryColor,
  }) {
    return inputDecoration(context, hint, primaryColor: primaryColor);
  }

  /// Standard Card/Container Decoration for wrapping sections
  static BoxDecoration cardDecoration(BuildContext context) {
    final theme = Theme.of(context);

    return BoxDecoration(
      color: theme.cardColor, // Usually white in light mode
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: theme.dividerColor.withOpacity(0.5),
        width: 1.5,
      ),
    );
  }

  /// Decoration for clickable chips (like the Male/Female gender chips)
  static BoxDecoration chipDecoration(
    BuildContext context, {
    bool isSelected = false,
    Color? activeColor,
  }) {
    final theme = Theme.of(context);
    final color = activeColor ?? theme.colorScheme.primary;

    return BoxDecoration(
      color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isSelected ? color.withOpacity(0.5) : Colors.grey.shade200,
      ),
    );
  }
}
