import 'package:flutter/material.dart' as material;
import 'package:querya_desktop/core/layout/ui_scale.dart';
import 'package:querya_desktop/core/theme/querya_theme_scope.dart';
import 'package:querya_desktop/shared/widgets/querya_action_menu.dart'
    show QueryaActionMenuItem;
import 'package:querya_desktop/shared/widgets/querya_dropdown_tokens.dart';

/// The popup surface every Querya menu shares with `QueryaDropdown`: popover
/// fill, border, radius, soft shadow, compact rows, no ripple (#1335).
material.MenuStyle queryaMenuStyle(material.BuildContext context) {
  final cs = context.colors;
  final radius = context.scaled(QueryaDropdownTokens.menuBorderRadius);
  return material.MenuStyle(
    backgroundColor: material.WidgetStatePropertyAll(cs.popover),
    surfaceTintColor: material.WidgetStatePropertyAll(cs.popover),
    elevation: const material.WidgetStatePropertyAll(
      QueryaDropdownTokens.menuElevation,
    ),
    shadowColor: const material.WidgetStatePropertyAll(
      QueryaDropdownTokens.menuShadowColor,
    ),
    padding: const material.WidgetStatePropertyAll(
      QueryaDropdownTokens.menuPadding,
    ),
    shape: material.WidgetStatePropertyAll(
      material.RoundedRectangleBorder(
        borderRadius: material.BorderRadius.circular(radius),
        side: material.BorderSide(color: cs.border),
      ),
    ),
  );
}

/// Where a menu opens relative to its trigger.
material.Offset queryaMenuAlignmentOffset(material.BuildContext context) =>
    material.Offset(
      0,
      context.scaled(QueryaDropdownTokens.menuAlignmentOffset.dy),
    );

/// The command rows of a menu.
List<material.Widget> queryaMenuItems<T>(
  material.BuildContext context,
  List<QueryaActionMenuItem<T>> items,
  material.ValueChanged<T> onSelected,
) {
  final cs = context.colors;
  final radius = context.scaled(QueryaDropdownTokens.menuBorderRadius);
  return [
    for (final item in items)
      material.MenuItemButton(
        style: material.MenuItemButton.styleFrom(
          minimumSize: material.Size(
            0,
            QueryaDropdownTokens.scaledMenuItemHeight(context),
          ),
          padding: material.EdgeInsets.symmetric(
            horizontal: context.scaled(8),
          ),
          foregroundColor: cs.popoverForeground,
          overlayColor: cs.accent.withValues(alpha: 0.14),
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.circular(radius),
          ),
        ),
        leadingIcon: item.icon == null
            ? null
            : material.Icon(
                item.icon,
                size: context.scaled(16),
                color: cs.mutedForeground,
              ),
        onPressed: () => onSelected(item.value),
        child: material.Text(
          item.label,
          style: QueryaDropdownTokens.menuItemTextStyle(
            context,
            cs.popoverForeground,
            selected: false,
          ),
        ),
      ),
  ];
}
