import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:querya_desktop/core/layout/ui_scale.dart';
import 'package:querya_desktop/core/theme/querya_theme_scope.dart';
import 'package:querya_desktop/core/ui/querya_control_tokens.dart';
import 'package:querya_desktop/shared/widgets/querya_button.dart';

/// The footer row of a dialog (docs/ui-kit.md, "Dialog footers"; #1335):
///
/// ```
/// [ leading ]                 [ Cancel ]  [ Secondary… ]  [ Primary ]
/// ```
///
/// - Everything is `lg`, 8 apart, right-aligned, under a divider.
/// - **One** main action: [primary] or [destructive], never both; in debug the
///   variants of every slot are checked (cancel is ghost, secondary slots are
///   secondary, the main one is primary / destructive).
/// - `Esc` runs [cancel] while focus is in the footer. For `Esc` and `Enter`
///   across the whole dialog wrap its body in a `CallbackShortcuts` with
///   [QueryaDialogActions.bindings].
class QueryaDialogActions extends material.StatelessWidget {
  const QueryaDialogActions({
    super.key,
    this.cancel,
    this.secondary = const [],
    this.primary,
    this.destructive,
    this.leading,
    this.showDivider = true,
  }) : assert(
          primary == null || destructive == null,
          'A dialog footer has one main action: primary or destructive, not both',
        );

  /// Cancel / Close: a [QueryaButtonVariant.ghost] button, placed first.
  final QueryaButton? cancel;

  /// Other actions (Test connection, Save as draft): `secondary` buttons.
  final List<QueryaButton> secondary;

  /// The main action: a [QueryaButtonVariant.primary] button.
  final QueryaButton? primary;

  /// The main action when it is irreversible: a
  /// [QueryaButtonVariant.destructive] button.
  final QueryaButton? destructive;

  /// Something left-aligned in the footer (a status, a checkbox).
  final material.Widget? leading;
  final bool showDivider;

  QueryaButton? get _main => primary ?? destructive;

  /// `Esc` -> cancel and `Enter` -> the main action, for the dialog's
  /// `CallbackShortcuts`. A disabled button is not run.
  static Map<material.ShortcutActivator, material.VoidCallback> bindings({
    QueryaButton? cancel,
    QueryaButton? primary,
    QueryaButton? destructive,
  }) {
    final main = primary ?? destructive;
    return {
      if (cancel?.onPressed != null)
        const material.SingleActivator(LogicalKeyboardKey.escape):
            cancel!.onPressed!,
      if (main?.onPressed != null && main?.loading != true)
        const material.SingleActivator(LogicalKeyboardKey.enter):
            main!.onPressed!,
    };
  }

  @override
  material.Widget build(material.BuildContext context) {
    assert(() {
      final c = cancel;
      if (c != null && c.variant != QueryaButtonVariant.ghost) {
        throw material.FlutterError(
          'QueryaDialogActions.cancel must be a ghost button, got '
          '${c.variant.name}.',
        );
      }
      for (final s in secondary) {
        if (s.variant != QueryaButtonVariant.secondary) {
          throw material.FlutterError(
            'QueryaDialogActions.secondary buttons must be secondary, got '
            '${s.variant.name}.',
          );
        }
      }
      final p = primary;
      if (p != null && p.variant != QueryaButtonVariant.primary) {
        throw material.FlutterError(
          'QueryaDialogActions.primary must be a primary button, got '
          '${p.variant.name}.',
        );
      }
      final d = destructive;
      if (d != null && d.variant != QueryaButtonVariant.destructive) {
        throw material.FlutterError(
          'QueryaDialogActions.destructive must be a destructive button, got '
          '${d.variant.name}.',
        );
      }
      return true;
    }());

    final wb = context.workbench;
    final gap = context.scaled(8);
    final buttons = <material.Widget>[
      if (cancel != null) cancel!,
      ...secondary,
      if (_main != null) _main!,
    ];

    final row = material.Row(
      children: [
        if (leading != null) material.Flexible(child: leading!),
        const material.Spacer(),
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) material.SizedBox(width: gap),
          buttons[i],
        ],
      ],
    );

    final footer = material.CallbackShortcuts(
      bindings: {
        if (cancel?.onPressed != null)
          const material.SingleActivator(LogicalKeyboardKey.escape):
              cancel!.onPressed!,
      },
      child: QueryaControlScope(
        size: QueryaControlSize.lg,
        child: material.Padding(
          padding: const material.EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: row,
        ),
      ),
    );

    if (!showDivider) return footer;
    return material.Column(
      mainAxisSize: material.MainAxisSize.min,
      crossAxisAlignment: material.CrossAxisAlignment.stretch,
      children: [
        material.SizedBox(
          height: 1,
          child: material.ColoredBox(color: wb.borderSubtle),
        ),
        footer,
      ],
    );
  }
}
