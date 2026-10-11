import 'package:flutter/material.dart' as material;
import 'package:querya_desktop/core/theme/querya_theme_scope.dart';
import 'package:querya_desktop/core/ui/querya_control_tokens.dart';
import 'package:querya_desktop/shared/widgets/querya_action_menu.dart'
    show QueryaActionMenuItem;
import 'package:querya_desktop/shared/widgets/querya_button.dart';
import 'package:querya_desktop/shared/widgets/querya_menu_surface.dart';

/// A primary action and a chevron that opens a menu of related actions
/// (Execute + Explain / Run selection), as one control (#1335): one outline and
/// radius, equal height, a divider between the halves instead of a gap, its own
/// tooltip on each half, and a [loading] state that disables both.
///
/// ```dart
/// QueryaSplitButton<String>(
///   label: 'Execute',
///   icon: Icons.play_arrow_rounded,
///   onPressed: _run,
///   items: const [QueryaActionMenuItem(value: 'explain', label: 'Explain')],
///   onSelected: _runCommand,
/// )
/// ```
class QueryaSplitButton<T> extends material.StatelessWidget {
  const QueryaSplitButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.items,
    required this.onSelected,
    this.icon,
    this.variant = QueryaButtonVariant.primary,
    this.size,
    this.loading = false,
    this.tooltip,
    this.shortcutHint,
    this.menuTooltip = 'More actions',
    this.compact = false,
    this.mainKey,
    this.menuKey,
  });

  final String label;
  final material.IconData? icon;

  /// The main action; `null` disables the whole control.
  final material.VoidCallback? onPressed;
  final List<QueryaActionMenuItem<T>> items;
  final material.ValueChanged<T> onSelected;

  /// How the control looks. [QueryaButtonVariant.secondary] and `ghost` draw
  /// one outline (secondary only) around both halves.
  final QueryaButtonVariant variant;
  final QueryaControlSize? size;

  /// Shows a spinner on the main half and disables both halves.
  final bool loading;
  final String? tooltip;
  final String? shortcutHint;

  /// Tooltip and spoken label of the chevron half.
  final String menuTooltip;

  /// Icon only on the main half (narrow toolbars); the label becomes its
  /// tooltip.
  final bool compact;

  /// Keys of the two halves (tests and shortcuts target them separately).
  final material.Key? mainKey;
  final material.Key? menuKey;

  @override
  material.Widget build(material.BuildContext context) {
    final wb = context.workbenchOrDefault;
    final controlSize = size ?? QueryaControlSize.of(context);
    final radius =
        material.BorderRadius.circular(controlSize.scaledRadius(context));
    final filled = variant == QueryaButtonVariant.primary ||
        variant == QueryaButtonVariant.destructive;
    // The outline of a secondary control is drawn once, around both halves.
    final halfVariant =
        filled ? variant : QueryaButtonVariant.ghost;
    final divider = filled
        ? wb.onAccent.withValues(alpha: 0.35)
        : wb.borderSubtle;
    final enabled = onPressed != null && !loading;

    final main = QueryaButton(
      key: mainKey,
      variant: halfVariant,
      compact: compact,
      label: label,
      icon: icon,
      onPressed: onPressed,
      loading: loading,
      tooltip: tooltip,
      shortcutHint: shortcutHint,
      size: controlSize,
      borderRadius: material.BorderRadius.zero,
    );

    final chevron = material.MenuAnchor(
      alignmentOffset: queryaMenuAlignmentOffset(context),
      consumeOutsideTap: true,
      style: queryaMenuStyle(context),
      menuChildren: queryaMenuItems<T>(context, items, onSelected),
      builder: (context, controller, _) => QueryaButton(
        key: menuKey,
        variant: halfVariant,
        icon: material.Icons.keyboard_arrow_down_rounded,
        semanticLabel: menuTooltip,
        tooltip: menuTooltip,
        isActive: controller.isOpen,
        size: controlSize,
        borderRadius: material.BorderRadius.zero,
        onPressed: enabled
            ? () => controller.isOpen ? controller.close() : controller.open()
            : null,
      ),
    );

    return material.ClipRRect(
      borderRadius: radius,
      child: material.DecoratedBox(
        position: material.DecorationPosition.foreground,
        decoration: material.BoxDecoration(
          borderRadius: radius,
          border: variant == QueryaButtonVariant.secondary
              ? material.Border.all(color: wb.borderSubtle)
              : null,
        ),
        child: material.Row(
          mainAxisSize: material.MainAxisSize.min,
          children: [
            main,
            material.SizedBox(
              width: 1,
              height: controlSize.scaledHeight(context),
              child: material.ColoredBox(color: divider),
            ),
            chevron,
          ],
        ),
      ),
    );
  }
}
