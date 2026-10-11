import 'package:flutter/material.dart' as material;
import 'package:querya_desktop/core/ui/querya_control_tokens.dart';
import 'package:querya_desktop/core/ui/querya_tooltip.dart';
import 'package:querya_desktop/shared/widgets/querya_button.dart';

/// Labelled toolbar button: optional leading icon, a [loading] state and a
/// destructive tone. A thin wrapper over [QueryaButton.secondary]; new code
/// uses [QueryaButton] directly (epic #1331).
///
/// While [loading] the button is disabled and shows a spinner in place of
/// [icon]. With [isDestructive] the label and icon use the workbench
/// destructive colour.
class QueryaActionButton extends material.StatelessWidget {
  const QueryaActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.isDestructive = false,
    this.tooltip,
    this.size,
    this.compact = false,
  });

  final String label;
  final material.IconData? icon;

  /// `null` disables the button.
  final material.VoidCallback? onPressed;

  /// Shows a spinner instead of [icon] and disables the button.
  final bool loading;

  /// Uses the destructive colour for the icon and the label.
  final bool isDestructive;

  /// Shown on hover after [kQueryaTooltipWait].
  final String? tooltip;

  /// Control size; without one the nearest `QueryaControlScope`, then `md`.
  final QueryaControlSize? size;

  /// Hides the label and keeps the icon (narrow toolbars). The label becomes
  /// the tooltip when none is set. Without an [icon], [compact] has no effect.
  final bool compact;

  @override
  material.Widget build(material.BuildContext context) {
    return QueryaButton.secondary(
      label: label,
      icon: icon,
      onPressed: onPressed,
      loading: loading,
      tooltip: tooltip,
      size: size,
      compact: compact,
      tone: isDestructive
          ? QueryaButtonTone.destructive
          : QueryaButtonTone.normal,
    );
  }
}
