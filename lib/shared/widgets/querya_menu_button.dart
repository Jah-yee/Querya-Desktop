import 'package:flutter/material.dart' as material;
import 'package:querya_desktop/core/ui/querya_control_tokens.dart';
import 'package:querya_desktop/shared/widgets/querya_action_menu.dart'
    show QueryaActionMenuItem;
import 'package:querya_desktop/shared/widgets/querya_button.dart';
import 'package:querya_desktop/shared/widgets/querya_menu_surface.dart';

/// A button that opens a menu of commands (#1335): a [QueryaButton] with a
/// trailing chevron, shown as active while the menu is open. The menu surface
/// is the one `QueryaDropdown` uses.
///
/// It replaces the trigger of `QueryaActionMenu` / `ExportMenuButton`, so a
/// menu next to a button in a toolbar has the same height and states.
class QueryaMenuButton<T> extends material.StatelessWidget {
  const QueryaMenuButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.label,
    this.icon,
    this.variant = QueryaButtonVariant.secondary,
    this.tone = QueryaButtonTone.normal,
    this.size,
    this.tooltip,
    this.compact = false,
    this.enabled = true,
    this.menuController,
  }) : assert(
          label != null || icon != null,
          'A QueryaMenuButton needs a label, an icon, or both',
        );

  final List<QueryaActionMenuItem<T>> items;
  final material.ValueChanged<T> onSelected;

  /// The text; null for an icon-only trigger.
  final String? label;
  final material.IconData? icon;

  /// [QueryaButtonVariant.secondary] by default; [QueryaButtonVariant.ghost]
  /// for toolbars.
  final QueryaButtonVariant variant;
  final QueryaButtonTone tone;
  final QueryaControlSize? size;
  final String? tooltip;

  /// Icon only on narrow toolbars; the label becomes the tooltip.
  final bool compact;
  final bool enabled;

  /// Optional external controller, to open or close the menu from code.
  final material.MenuController? menuController;

  @override
  material.Widget build(material.BuildContext context) {
    final controlSize = size ?? QueryaControlSize.of(context);
    return material.MenuAnchor(
      controller: menuController,
      alignmentOffset: queryaMenuAlignmentOffset(context),
      consumeOutsideTap: true,
      style: queryaMenuStyle(context),
      menuChildren: queryaMenuItems<T>(context, items, onSelected),
      builder: (context, controller, _) => QueryaButton(
        variant: variant,
        tone: tone,
        label: label,
        icon: icon,
        size: size,
        tooltip: tooltip,
        compact: compact,
        isActive: controller.isOpen,
        trailing: material.Icon(
          material.Icons.keyboard_arrow_down_rounded,
          size: controlSize.scaledIconSize(context),
        ),
        onPressed: enabled
            ? () => controller.isOpen ? controller.close() : controller.open()
            : null,
      ),
    );
  }
}
