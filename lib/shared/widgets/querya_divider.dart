import 'package:flutter/material.dart' as material;
import 'package:querya_desktop/core/theme/querya_theme_scope.dart';

/// A hairline rule in the workbench border colour (#1443).
///
/// Replaces Material's `Divider` / `VerticalDivider`, which read the Material
/// `dividerColor` and come out near-black in the light theme. Without a
/// [color] the rule is `workbench.borderSubtle`; [height] (or [width] for
/// [QueryaDivider.vertical]) is the space the rule occupies, [thickness] the
/// line itself.
class QueryaDivider extends material.StatelessWidget {
  /// A horizontal rule, [height] tall (default 1).
  const QueryaDivider({
    super.key,
    this.height = 1,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  }) : vertical = false;

  /// A vertical rule, [width] wide (passed as `height` of the shared fields).
  const QueryaDivider.vertical({
    super.key,
    double width = 1,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  })  : height = width,
        vertical = true;

  final double height;
  final double thickness;

  /// Space before the rule (left / top).
  final double indent;

  /// Space after the rule (right / bottom).
  final double endIndent;

  /// Overrides `workbench.borderSubtle`.
  final material.Color? color;

  /// Whether the rule is vertical (`.vertical`), [height] is then its width.
  final bool vertical;

  @override
  material.Widget build(material.BuildContext context) {
    final ruleColor = color ?? context.workbenchOrDefault.borderSubtle;
    final line = material.ColoredBox(color: ruleColor);
    if (vertical) {
      return material.SizedBox(
        width: height,
        child: material.Center(
          child: material.Padding(
            padding: material.EdgeInsets.only(top: indent, bottom: endIndent),
            child: material.SizedBox(width: thickness, child: line),
          ),
        ),
      );
    }
    return material.SizedBox(
      height: height,
      child: material.Center(
        child: material.Padding(
          padding: material.EdgeInsets.only(left: indent, right: endIndent),
          child: material.SizedBox(height: thickness, child: line),
        ),
      ),
    );
  }
}
