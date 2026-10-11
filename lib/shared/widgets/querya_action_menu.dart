import 'package:flutter/material.dart' as material;

/// One command row of a menu: [QueryaMenuButton] and [QueryaSplitButton] take a
/// list of these.
class QueryaActionMenuItem<T> {
  const QueryaActionMenuItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final material.IconData? icon;
}
