import 'package:flutter/material.dart' as material;
import 'package:querya_desktop/core/theme/querya_theme_scope.dart';
import 'package:querya_desktop/core/ui/querya_control_tokens.dart';
import 'package:querya_desktop/shared/widgets/querya_button.dart';

/// One segment of a [QueryaButtonGroup]: a label and / or an icon and its
/// action. Give [isActive] to a segment that reflects the current choice.
class QueryaButtonGroupItem {
  const QueryaButtonGroupItem({
    this.label,
    this.icon,
    this.tooltip,
    this.semanticLabel,
    this.onPressed,
    this.isActive = false,
    this.key,
  }) : assert(
          label != null || icon != null,
          'A group segment needs a label or an icon',
        );

  final String? label;
  final material.IconData? icon;
  final String? tooltip;

  /// Spoken label of an icon-only segment (falls back to [tooltip]).
  final String? semanticLabel;

  /// `null` disables the segment.
  final material.VoidCallback? onPressed;
  final bool isActive;
  final material.Key? key;
}

/// Related actions drawn as one segmented control (#1335): one outline and
/// radius, equal height, a 1 px divider between segments instead of a gap.
///
/// Use it for actions that are *not* views of the same content (Depth 1 /
/// Depth 2, Zoom - / +); switching between views is [QueryaTabStrip].
///
/// ```dart
/// QueryaButtonGroup(
///   items: [
///     QueryaButtonGroupItem(label: 'Depth 1', isActive: d == 1, onPressed: () => setD(1)),
///     QueryaButtonGroupItem(label: 'Depth 2', isActive: d == 2, onPressed: () => setD(2)),
///   ],
/// )
/// ```
class QueryaButtonGroup extends material.StatelessWidget {
  const QueryaButtonGroup({super.key, required this.items, this.size})
      : assert(items.length > 0, 'A button group needs at least one segment');

  final List<QueryaButtonGroupItem> items;

  /// Control size; without one the nearest `QueryaControlScope`, then `md`.
  final QueryaControlSize? size;

  @override
  material.Widget build(material.BuildContext context) {
    final wb = context.workbenchOrDefault;
    final controlSize = size ?? QueryaControlSize.of(context);
    final radius =
        material.BorderRadius.circular(controlSize.scaledRadius(context));
    final height = controlSize.scaledHeight(context);

    final children = <material.Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (i > 0) {
        children.add(
          material.SizedBox(
            width: 1,
            height: height,
            child: material.ColoredBox(color: wb.borderSubtle),
          ),
        );
      }
      children.add(
        QueryaButton(
          key: item.key,
          variant: QueryaButtonVariant.ghost,
          label: item.label,
          icon: item.icon,
          tooltip: item.tooltip,
          semanticLabel: item.semanticLabel ?? item.tooltip,
          isActive: item.isActive,
          onPressed: item.onPressed,
          size: controlSize,
          borderRadius: material.BorderRadius.zero,
        ),
      );
    }

    return material.ClipRRect(
      borderRadius: radius,
      child: material.DecoratedBox(
        position: material.DecorationPosition.foreground,
        decoration: material.BoxDecoration(
          borderRadius: radius,
          border: material.Border.all(color: wb.borderSubtle),
        ),
        child: material.Row(
          mainAxisSize: material.MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
